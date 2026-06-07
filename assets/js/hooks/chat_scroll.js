const ChatScroll = {
  mounted() {
    this.scrollToBottom();
    this.handleEvent("chat-scroll", () => this.scrollToBottom());
  },

  updated() {
    this.scrollToBottom();
  },

  scrollToBottom() {
    this.el.scrollTop = this.el.scrollHeight;
  },
};

export default ChatScroll;
