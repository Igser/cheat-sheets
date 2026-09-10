// Пользователь приложения поверх root'а — чтобы тренировать выдачу прав, а не сидеть под админом.
db = db.getSiblingDB('practice');
db.createUser({
  user: 'app',
  pwd: 'secret',
  roles: [{ role: 'readWrite', db: 'practice' }]
});
db.createCollection('orders');
