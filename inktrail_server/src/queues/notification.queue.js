/**
 * Notification dispatch.
 *
 * Ưu tiên độ tin cậy cho UX realtime của app:
 * - Mặc định ghi notification đồng bộ để đảm bảo người dùng thấy ngay.
 * - Chỉ enqueue khi bật cờ `NOTIFICATION_USE_QUEUE=true`.
 */
const { createQueue } = require("../config/queue");

const NOTIFICATION_QUEUE_NAME = "notification";
const queue = createQueue(NOTIFICATION_QUEUE_NAME);

const dispatchNotification = async (payload) => {
  if (!payload || !payload.recipientId) return null;

  const useQueue = String(process.env.NOTIFICATION_USE_QUEUE || "").toLowerCase() === "true";

  if (useQueue && queue) {
    try {
      return await queue.add("create", payload, {
        // Notification không cần idempotent jobId; mỗi lần dispatch là một
        // bản ghi mới (đa số là follow-up khác nhau).
      });
    } catch (error) {
      console.error("[notification-queue:enqueue-error]", {
        recipient_id: payload.recipientId,
        type: payload.type,
        message: error?.message || String(error),
      });
    }
  }

  const notificationService = require("../modules/notification/notification.service");
  return notificationService.createNotification(payload);
};

module.exports = {
  NOTIFICATION_QUEUE_NAME,
  notificationQueue: queue,
  dispatchNotification,
};
