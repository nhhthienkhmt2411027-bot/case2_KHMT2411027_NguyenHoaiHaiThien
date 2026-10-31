const express = require('express');
const cors = require('cors');
const taskRoutes = require('./routes/taskRoutes');
const errorMiddleware = require('./middleware/errorMiddleware');
const AppError = require('./utils/appError');

const app = express();

app.use(cors());
app.use(express.json());

// Routes
app.use('/api/v1/tasks', taskRoutes);

// Xử lý Route không tồn tại (404)
app.all('*', (req, res, next) => {
  next(new AppError(`Không tìm thấy đường dẫn ${req.originalUrl} trên máy chủ!`, 404));
});

// Middleware xử lý lỗi tập trung
app.use(errorMiddleware);

module.exports = app;