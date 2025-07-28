// Chat Application Class
class ChatApp {
    constructor() {
        this.currentChatId = null;
        this.chatHistory = [];
        this.isTyping = false;
        this.isLoggedIn = true; // Simulate logged in state
        
        this.initializeElements();
        this.bindEvents();
        this.loadChatHistory();
        this.createNewChat();
    }

    initializeElements() {
        // DOM Elements
        this.chatMessages = document.getElementById('chatMessages');
        this.messageInput = document.getElementById('messageInput');
        this.sendBtn = document.getElementById('sendBtn');
        this.logoutBtn = document.getElementById('logoutBtn');
        this.newChatBtn = document.getElementById('newChatBtn');
        this.newChatBtnDesktop = document.getElementById('newChatBtnDesktop');
        this.chatHistoryList = document.getElementById('chatHistoryList');
        this.chatHistoryListDesktop = document.getElementById('chatHistoryListDesktop');
        this.userSection = document.getElementById('userSection');
        
        // Bootstrap components
        this.sidebar = new bootstrap.Offcanvas(document.getElementById('chatSidebar'));
    }

    bindEvents() {
        // Send message events
        this.sendBtn.addEventListener('click', () => this.sendMessage());
        this.messageInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                this.sendMessage();
            }
        });

        // Auto-resize textarea on input
        this.messageInput.addEventListener('input', () => {
            this.messageInput.style.height = 'auto';
            this.messageInput.style.height = this.messageInput.scrollHeight + 'px';
        });

        // Logout event
        this.logoutBtn.addEventListener('click', () => this.logout());

        // New chat events (both mobile and desktop)
        this.newChatBtn.addEventListener('click', () => this.createNewChat());
        if (this.newChatBtnDesktop) {
            this.newChatBtnDesktop.addEventListener('click', () => this.createNewChat());
        }

        // Focus on message input
        this.messageInput.focus();
    }

    sendMessage() {
        const message = this.messageInput.value.trim();
        if (!message || this.isTyping) return;

        // Add user message
        this.addMessage(message, 'user');
        this.messageInput.value = '';
        this.messageInput.style.height = 'auto';

        // Show typing indicator
        this.showTypingIndicator();

        // Simulate API call with delay
        setTimeout(() => {
            this.hideTypingIndicator();
            const botResponse = this.generateMockResponse(message);
            this.addMessage(botResponse, 'bot');
            this.updateChatHistory();
        }, 1500 + Math.random() * 1000); // Random delay between 1.5-2.5 seconds
    }

    addMessage(text, sender) {
        const messageWrapper = document.createElement('div');
        messageWrapper.className = `message-wrapper ${sender}-message`;
        
        const currentTime = new Date().toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
        
        if (sender === 'user') {
            messageWrapper.innerHTML = `
                <div class="message message-sent">
                    <div class="message-text">${this.escapeHtml(text)}</div>
                    <div class="message-time">${currentTime}</div>
                </div>
            `;
        } else {
            messageWrapper.innerHTML = `
                <div class="message">
                    <div class="message-content">
                        <i class="fas fa-robot message-icon"></i>
                        <div class="message-text">${this.escapeHtml(text)}</div>
                    </div>
                    <div class="message-time">${currentTime}</div>
                </div>
            `;
        }

        this.chatMessages.appendChild(messageWrapper);
        this.scrollToBottom();

        // Store message in current chat
        if (this.currentChatId) {
            const chat = this.chatHistory.find(c => c.id === this.currentChatId);
            if (chat) {
                chat.messages.push({
                    text,
                    sender,
                    timestamp: new Date()
                });
                chat.lastMessage = text;
                chat.lastUpdate = new Date();
            }
        }
    }

    showTypingIndicator() {
        if (this.isTyping) return;
        
        this.isTyping = true;
        this.sendBtn.disabled = true;
        this.sendBtn.innerHTML = '<div class="loading"></div>';

        const typingWrapper = document.createElement('div');
        typingWrapper.className = 'message-wrapper bot-message typing-indicator-wrapper';
        typingWrapper.innerHTML = `
            <div class="typing-indicator">
                <i class="fas fa-robot message-icon"></i>
                <div class="typing-dots">
                    <div class="typing-dot"></div>
                    <div class="typing-dot"></div>
                    <div class="typing-dot"></div>
                </div>
            </div>
        `;

        this.chatMessages.appendChild(typingWrapper);
        this.scrollToBottom();
    }

    hideTypingIndicator() {
        this.isTyping = false;
        this.sendBtn.disabled = false;
        this.sendBtn.innerHTML = '<i class="fas fa-paper-plane"></i>';

        const typingIndicator = this.chatMessages.querySelector('.typing-indicator-wrapper');
        if (typingIndicator) {
            typingIndicator.remove();
        }
    }

    generateMockResponse(userMessage) {
        const responses = [
            "That's an interesting question! Let me think about that for a moment.",
            "I understand what you're asking. Here's what I think about that topic.",
            "Great question! Based on what you've told me, I'd suggest considering a few different approaches.",
            "I see what you mean. That's definitely something worth exploring further.",
            "Thanks for sharing that with me. I have some thoughts that might be helpful.",
            "That's a really good point. Let me break that down for you.",
            "I appreciate you bringing that up. Here's my perspective on the matter.",
            "Interesting! I've been thinking about similar topics lately.",
            "That's exactly the kind of question I love to help with.",
            "You've touched on something really important there."
        ];

        const followUps = [
            "What else would you like to know about this?",
            "Is there anything specific you'd like me to elaborate on?",
            "Would you like me to go deeper into any particular aspect?",
            "What are your thoughts on this approach?",
            "Does this help answer your question?",
            "Is there another angle you'd like to explore?",
            "What other questions do you have about this topic?",
            "Would you like some examples to illustrate this further?",
            "How does this relate to what you're working on?",
            "What would you like to discuss next?"
        ];

        const response = responses[Math.floor(Math.random() * responses.length)];
        const followUp = followUps[Math.floor(Math.random() * followUps.length)];
        
        return `${response}\n\n${followUp}`;
    }

    createNewChat() {
        const chatId = 'chat_' + Date.now();
        const newChat = {
            id: chatId,
            title: 'New Chat',
            messages: [],
            lastMessage: '',
            lastUpdate: new Date(),
            createdAt: new Date()
        };

        this.chatHistory.unshift(newChat);
        this.currentChatId = chatId;
        this.clearChatMessages();
        this.updateChatHistoryDisplay();
        
        // Close sidebar on mobile after creating new chat
        if (window.innerWidth < 768) {
            this.sidebar.hide();
        }

        // Add welcome message
        setTimeout(() => {
            this.addMessage("Hello! I'm your AI assistant. How can I help you today?", 'bot');
        }, 500);
    }

    clearChatMessages() {
        this.chatMessages.innerHTML = '';
    }

    loadChat(chatId) {
        const chat = this.chatHistory.find(c => c.id === chatId);
        if (!chat) return;

        this.currentChatId = chatId;
        this.clearChatMessages();

        // Load all messages from this chat
        chat.messages.forEach(msg => {
            const messageWrapper = document.createElement('div');
            messageWrapper.className = `message-wrapper ${msg.sender}-message`;
            
            const time = new Date(msg.timestamp).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
            
            if (msg.sender === 'user') {
                messageWrapper.innerHTML = `
                    <div class="message">
                        <div class="message-text">${this.escapeHtml(msg.text)}</div>
                        <div class="message-time">${time}</div>
                    </div>
                `;
            } else {
                messageWrapper.innerHTML = `
                    <div class="message">
                        <div class="message-content">
                            <i class="fas fa-robot message-icon"></i>
                            <div class="message-text">${this.escapeHtml(msg.text)}</div>
                        </div>
                        <div class="message-time">${time}</div>
                    </div>
                `;
            }

            this.chatMessages.appendChild(messageWrapper);
        });

        this.updateChatHistoryDisplay();
        this.scrollToBottom();
        
        // Close sidebar on mobile after selecting chat
        if (window.innerWidth < 768) {
            this.sidebar.hide();
        }
    }

    updateChatHistory() {
        // Update chat title based on first user message
        const chat = this.chatHistory.find(c => c.id === this.currentChatId);
        if (chat && chat.title === 'New Chat' && chat.messages.length > 0) {
            const firstUserMessage = chat.messages.find(m => m.sender === 'user');
            if (firstUserMessage) {
                chat.title = firstUserMessage.text.length > 30 
                    ? firstUserMessage.text.substring(0, 30) + '...'
                    : firstUserMessage.text;
            }
        }
        
        this.updateChatHistoryDisplay();
    }

    updateChatHistoryDisplay() {
        // Update both mobile and desktop chat history lists
        const containers = [this.chatHistoryList, this.chatHistoryListDesktop].filter(Boolean);
        
        containers.forEach(container => {
            container.innerHTML = '';

            if (this.chatHistory.length === 0) {
                container.innerHTML = `
                    <div class="empty-state">
                        <i class="fas fa-comments"></i>
                        <h5>No chats yet</h5>
                        <p>Start a new conversation to begin</p>
                    </div>
                `;
                return;
            }

            this.chatHistory.forEach(chat => {
                const chatItem = document.createElement('div');
                chatItem.className = `chat-history-item ${chat.id === this.currentChatId ? 'active' : ''}`;
                
                const timeAgo = this.getTimeAgo(chat.lastUpdate);
                const preview = chat.lastMessage.length > 50 
                    ? chat.lastMessage.substring(0, 50) + '...'
                    : chat.lastMessage || 'No messages yet';

                chatItem.innerHTML = `
                    <div class="chat-history-title">${this.escapeHtml(chat.title)}</div>
                    <div class="chat-history-preview">${this.escapeHtml(preview)}</div>
                    <div class="chat-history-time">${timeAgo}</div>
                `;

                chatItem.addEventListener('click', () => this.loadChat(chat.id));
                container.appendChild(chatItem);
            });
        });
    }

    loadChatHistory() {
        // Load from localStorage if available
        const saved = localStorage.getItem('chatHistory');
        if (saved) {
            try {
                this.chatHistory = JSON.parse(saved).map(chat => ({
                    ...chat,
                    lastUpdate: new Date(chat.lastUpdate),
                    createdAt: new Date(chat.createdAt),
                    messages: chat.messages.map(msg => ({
                        ...msg,
                        timestamp: new Date(msg.timestamp)
                    }))
                }));
            } catch (e) {
                console.error('Failed to load chat history:', e);
                this.chatHistory = [];
            }
        }
        this.updateChatHistoryDisplay();
    }

    saveChatHistory() {
        localStorage.setItem('chatHistory', JSON.stringify(this.chatHistory));
    }

    logout() {
        if (confirm('Are you sure you want to logout?')) {
            this.isLoggedIn = false;
            this.saveChatHistory();
            // Simulate logout - in a real app, this would redirect or clear auth tokens
            alert('You have been logged out successfully!');
            // You could redirect to a login page here
        }
    }

    scrollToBottom() {
        setTimeout(() => {
            this.chatMessages.scrollTop = this.chatMessages.scrollHeight;
        }, 100);
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    getTimeAgo(date) {
        const now = new Date();
        const diffMs = now - date;
        const diffMins = Math.floor(diffMs / 60000);
        const diffHours = Math.floor(diffMs / 3600000);
        const diffDays = Math.floor(diffMs / 86400000);

        if (diffMins < 1) return 'Just now';
        if (diffMins < 60) return `${diffMins}m ago`;
        if (diffHours < 24) return `${diffHours}h ago`;
        if (diffDays < 7) return `${diffDays}d ago`;
        return date.toLocaleDateString();
    }
}

// Additional utility functions
class ChatUtils {
    static formatMessage(text) {
        // Basic text formatting - convert URLs to links
        return text.replace(
            /(https?:\/\/[^\s]+)/g,
            '<a href="$1" target="_blank" rel="noopener noreferrer">$1</a>'
        );
    }

    static detectLanguage(text) {
        // Simple code detection for syntax highlighting
        const codePatterns = {
            javascript: /\b(function|const|let|var|=>|console\.log)\b/,
            python: /\b(def|import|print|class|if __name__)\b/,
            html: /<[^>]+>/,
            css: /\{[^}]*\}/
        };

        for (const [lang, pattern] of Object.entries(codePatterns)) {
            if (pattern.test(text)) {
                return lang;
            }
        }
        return null;
    }

    static generateChatId() {
        return 'chat_' + Math.random().toString(36).substr(2, 9) + '_' + Date.now();
    }
}

// Theme Manager
class ThemeManager {
    constructor() {
        this.currentTheme = localStorage.getItem('chatTheme') || 'light';
        this.applyTheme();
    }

    toggleTheme() {
        this.currentTheme = this.currentTheme === 'light' ? 'dark' : 'light';
        this.applyTheme();
        localStorage.setItem('chatTheme', this.currentTheme);
    }

    applyTheme() {
        document.body.setAttribute('data-theme', this.currentTheme);
    }
}

// Auto-save functionality
class AutoSave {
    constructor(chatApp) {
        this.chatApp = chatApp;
        this.saveInterval = 30000; // Save every 30 seconds
        this.startAutoSave();
    }

    startAutoSave() {
        setInterval(() => {
            this.chatApp.saveChatHistory();
        }, this.saveInterval);
    }
}

// Initialize the application when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    // Initialize the chat application
    const chatApp = new ChatApp();
    
    // Initialize theme manager
    const themeManager = new ThemeManager();
    
    // Initialize auto-save
    const autoSave = new AutoSave(chatApp);
    
    // Global error handling
    window.addEventListener('error', function(e) {
        console.error('Application error:', e.error);
    });

    // Handle beforeunload to save data
    window.addEventListener('beforeunload', function() {
        chatApp.saveChatHistory();
    });

    // Handle online/offline status
    window.addEventListener('online', function() {
        console.log('Application is online');
        // Update UI to show online status
    });

    window.addEventListener('offline', function() {
        console.log('Application is offline');
        // Update UI to show offline status
    });

    // Keyboard shortcuts
    document.addEventListener('keydown', function(e) {
        // Ctrl/Cmd + N for new chat
        if ((e.ctrlKey || e.metaKey) && e.key === 'n') {
            e.preventDefault();
            chatApp.createNewChat();
        }
        
        // Escape to close sidebar
        if (e.key === 'Escape') {
            const sidebar = bootstrap.Offcanvas.getInstance(document.getElementById('chatSidebar'));
            if (sidebar) {
                sidebar.hide();
            }
        }
    });

    // Make chatApp globally accessible for debugging
    window.chatApp = chatApp;
    
    console.log('Chat application initialized successfully!');
});
