require('dotenv').config();
const mongoose = require('mongoose');
const app = require('./app');

const PORT = process.env.PORT || 5000;
const DB_URI = process.env.DATABASE_URI;

mongoose
  .connect(DB_URI)
  .then(() => console.log('Kết nối Database thành công!'))
  .catch((err) => console.error('Lỗi kết nối Database:', err));

app.listen(PORT, () => {
  console.log(`Server đang chạy tại port ${PORT}...`);
});