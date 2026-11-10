const nodemailer = require('nodemailer');

class EmailService {
  constructor() {
    // Cấu hình transporter (dùng SMTP như Gmail, Mailtrap hoặc SendGrid)
    this.transporter = nodemailer.createTransport({
      host: process.env.EMAIL_HOST || 'smtp.mailtrap.io',
      port: process.env.EMAIL_PORT || 2525,
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
    });
  }

  // Hàm gửi email chung
  async send(to, subject, html) {
    const mailOptions = {
      from: `Task Manager Team <${process.env.EMAIL_FROM || 'no-reply@taskmanager.com'}>`,
      to,
      subject,
      html,
    };

    return await this.transporter.sendMail(mailOptions);
  }

  // Email chào mừng thành viên mới
  async sendWelcomeEmail(user) {
    const subject = 'Chào mừng bạn đến với Task Manager API!';
    const html = `
      <div style="font-family: Arial, sans-serif; padding: 20px;">
        <h2>Xin chào ${user.name}! 👋</h2>
        <p>Cảm ơn bạn đã đăng ký tài khoản tại hệ thống quản lý công việc của chúng tôi.</p>
        <p>Bắt đầu tạo và quản lý các công việc của bạn ngay hôm nay nhé!</p>
        <br>
        <p>Thân ái,<br>Đội ngũ Task Manager</p>
      </div>
    `;
    await this.send(user.email, subject, html);
  }

  // Email thông báo khi được giao nhiệm vụ
  async sendTaskAssignmentEmail(userEmail, task) {
    const subject = `[Task New] Bạn được giao công việc: ${task.title}`;
    const html = `
      <div style="font-family: Arial, sans-serif; padding: 20px;">
        <h2>Thông báo nhiệm vụ mới 📋</h2>
        <p>Bạn vừa được giao một công việc mới trên hệ thống:</p>
        <ul>
          <li><strong>Tiêu đề:</strong> ${task.title}</li>
          <li><strong>Độ ưu tiên:</strong> ${task.priority}</li>
          <li><strong>Hạn hoàn thành:</strong> ${task.dueDate ? new Date(task.dueDate).toLocaleDateString('vi-VN') : 'Không có'}</li>
        </ul>
        <p>Vui lòng kiểm tra và cập nhật tiến độ công việc đúng hạn.</p>
      </div>
    `;
    await this.send(userEmail, subject, html);
  }
}

module.exports = new EmailService();