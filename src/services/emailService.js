const nodemailer = require('nodemailer');

class EmailService {
  constructor() {
    this.transporter = nodemailer.createTransport({
      host: process.env.EMAIL_HOST || 'smtp.mailtrap.io',
      port: process.env.EMAIL_PORT || 2525,
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
    });
  }

  async send(to, subject, html) {
    const mailOptions = {
      from: `Task Manager Team <${process.env.EMAIL_FROM || 'no-reply@taskmanager.com'}>`,
      to,
      subject,
      html,
    };
    return await this.transporter.sendMail(mailOptions);
  }

  async sendWelcomeEmail(user) {
    const subject = 'Chào mừng bạn đến với Task Manager!';
    const html = `<h2>Xin chào ${user.name}!</h2><p>Cảm ơn bạn đã đăng ký tài khoản tại hệ thống của chúng tôi.</p>`;
    await this.send(user.email, subject, html);
  }

  async sendTaskAssignmentEmail(userEmail, task) {
    const subject = `[Task Manager] Nhiệm vụ mới: ${task.title}`;
    const html = `<h2>Bạn có nhiệm vụ mới</h2><p>Tiêu đề: ${task.title}</p>`;
    await this.send(userEmail, subject, html);
  }
}

module.exports = new EmailService();