// Bọc các async controller để tự động đẩy lỗi về errorMiddleware mà không cần try-catch
module.exports = (fn) => {
  return (req, res, next) => {
    fn(req, res, next).catch(next);
  };
};