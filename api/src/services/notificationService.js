const Notification = require('../models/Notification');

class NotificationService {
  async createNotification(recipientId, message) {
    return await Notification.create({
      recipient: recipientId,
      message,
    });
  }
}

module.exports = new NotificationService();