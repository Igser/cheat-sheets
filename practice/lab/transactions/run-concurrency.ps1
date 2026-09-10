# Прогон конкурентных сценариев через pgbench.
# Показывает две вещи, которые невозможно увидеть в одиночной сессии:
# оверселл при наивном коде и стоимость дедлоков.
#
#   .\run-concurrency.ps1              # всё
#   .\run-concurrency.ps1 -Only oversell
#   .\run-concurrency.ps1 -Only deadlock
#   .\run-concurrency.ps1 -Clients 50 -Tx 1

param(
    [ValidateSet('all', 'oversell', 'deadlock')]
    [string]$Only = 'all',
    [int]$Clients = 50,
    [int]$Tx = 1
)

$ErrorActionPreference = 'Stop'
$scripts = Join-Path $PSScriptRoot 'pgbench'

function Reset-Lab([int]$qty = 1) {
    docker exec cs-postgres psql -U practice -d practice -qc "SELECT lab.reset($qty);" | Out-Null
}

function Invoke-Bench($file, $clients, $tx, $extra = @()) {
    $bargs = @('-U', 'practice', '-d', 'practice', '-n',
              '-c', $clients, '-j', [Math]::Min(8, $clients), '-t', $tx,
              '--failures-detailed') + $extra + @('-f', "/tmp/pgb/$file")
    $out = docker exec cs-postgres pgbench @bargs 2>&1 | Out-String
    [pscustomobject]@{
        processed = [regex]::Match($out, 'actually processed: (\d+)').Groups[1].Value
        deadlocks = [regex]::Match($out, 'deadlock failures: (\d+)').Groups[1].Value
        retries   = [regex]::Match($out, 'total number of retries: (\d+)').Groups[1].Value
        tps       = [math]::Round([double]([regex]::Match($out, 'tps = ([\d.]+)').Groups[1].Value), 0)
    }
}

function Get-StockState {
    docker exec cs-postgres psql -U practice -d practice -tAc `
        "SELECT (SELECT qty FROM lab.stock WHERE product_id=1) || '|' || (SELECT count(*) FROM lab.orders)"
}

# Скрипты должны лежать внутри контейнера
docker cp $scripts cs-postgres:/tmp/pgb | Out-Null

if ($Only -in 'all', 'oversell') {
    Write-Host "`n=== Оверселл: $Clients покупателей, 1 товар на складе ===" -ForegroundColor Cyan
    $rows = foreach ($variant in @(
        @{ file = 'buy_naive.sql';      name = 'наивно: SELECT, проверка в коде, UPDATE' },
        @{ file = 'buy_for_update.sql'; name = 'FOR UPDATE: пессимистичная блокировка' },
        @{ file = 'buy_atomic.sql';     name = 'атомарный UPDATE ... WHERE qty > 0' }
    )) {
        Reset-Lab 1
        $r = Invoke-Bench $variant.file $Clients $Tx
        $state = (Get-StockState) -split '\|'
        [pscustomobject]@{
            'Вариант'   = $variant.name
            'Остаток'   = $state[0]
            'Заказов'   = $state[1]
            'Оверселл'  = if ([int]$state[1] -gt 1) { "ДА, продано $($state[1]) шт" } else { 'нет' }
            'tps'       = $r.tps
        }
    }
    $rows | Format-Table -AutoSize
    Write-Host "Ожидаемо: наивный вариант продаёт один товар всем подряд." -ForegroundColor DarkGray
}

if ($Only -in 'all', 'deadlock') {
    # Дедлоки дорогие: каждый стоит deadlock_timeout = 1s. Клиентов берём меньше.
    $dc = [Math]::Min($Clients, 10)
    $dt = [Math]::Max($Tx, 5)
    Write-Host "`n=== Дедлоки: $dc клиентов x $dt транзакций, перевод между двумя счетами ===" -ForegroundColor Cyan
    Write-Host "Прогон с ретраями занимает пару минут: каждая попытка ждёт deadlock_timeout." -ForegroundColor DarkGray

    $rows = foreach ($variant in @(
        @{ file = 'deadlock.sql';         name = 'случайный порядок, без ретраев'; extra = @() },
        @{ file = 'deadlock.sql';         name = 'случайный порядок + --max-tries 10'; extra = @('--max-tries', '10') },
        @{ file = 'deadlock_ordered.sql'; name = 'единый порядок захвата по id'; extra = @() }
    )) {
        Reset-Lab 1
        $sw = [Diagnostics.Stopwatch]::StartNew()
        $r = Invoke-Bench $variant.file $dc $dt $variant.extra
        $sw.Stop()
        [pscustomobject]@{
            'Вариант'  = $variant.name
            'Прошло'   = "$($r.processed)/$($dc * $dt)"
            'Дедлоков' = $r.deadlocks
            'Ретраев'  = if ($r.retries) { $r.retries } else { '-' }
            'Время, с' = [math]::Round($sw.Elapsed.TotalSeconds, 1)
        }
    }
    $rows | Format-Table -AutoSize
    Write-Host "Вывод: ретрай снижает потери, но не убирает их. Убирает — порядок захвата." -ForegroundColor DarkGray
}
