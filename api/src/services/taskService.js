const Task = require('../models/Task');
const User = require('../models/User');
const AppError = require('../utils/appError');
const notificationService = require('./notificationService');
const emailService = require('./emailService');

class TaskService {
  async createTask(taskData, creatorId) {
    let assigneeUser = null;

    if (taskData.assignedTo) {
      assigneeUser = await User.findById(taskData.assignedTo);
      if (!assigneeUser) throw new AppError('Người được gán công việc không tồn tại', 404);
    }

    const task = await Task.create({ ...taskData, createdBy: creatorId });

    if (assigneeUser) {
      await notificationService.createNotification(
        task.assignedTo,
        `Bạn vừa được giao công việc mới: ${task.title}`
      );
      emailService.sendTaskAssignmentEmail(assigneeUser.email, task).catch(console.error);
    }

    return task;
  }

  async getAllTasks(userId) {
    return await Task.find({ $or: [{ createdBy: userId }, { assignedTo: userId }] })
      .populate('assignedTo', 'name email')
      .sort('-createdAt');
  }

  async updateTaskStatus(taskId, status, userId) {
    const task = await Task.findById(taskId);
    if (!task) throw new AppError('Không tìm thấy công việc', 404);

    if (task.createdBy.toString() !== userId && task.assignedTo?.toString() !== userId) {
      throw new AppError('Bạn không có quyền cập nhật công việc này', 403);
    }

    task.status = status;
    await task.save();
    return task;
  }
}

module.exports = new TaskService();