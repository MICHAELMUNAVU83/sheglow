const STORAGE_KEY = "sheglow_chat_session_id";

const ChatPersist = {
  mounted() {
    const sessionId = localStorage.getItem(STORAGE_KEY);
    if (sessionId) {
      this.pushEvent("restore_chat", { session_id: sessionId });
    }

    this.handleEvent("save-chat", ({ session_id }) => {
      if (session_id) {
        localStorage.setItem(STORAGE_KEY, session_id);
      }
    });

    this.handleEvent("clear-chat", () => {
      localStorage.removeItem(STORAGE_KEY);
    });
  },
};

export default ChatPersist;
