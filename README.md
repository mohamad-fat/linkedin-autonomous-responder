# LinkedIn Automation: Invite Acceptor & AI Message Responder

An automated LinkedIn workflow built with **n8n** and **Unipile API (v2)** that automatically accepts incoming connection requests and replies to direct messages using **Google Gemini**.

---

## 1. What It Does

This project runs two automated workflows inside n8n:

### Workflow 1: Auto-Accept Connection Invitations
`Gmail Trigger` ➔ `Wait` ➔ `HTTP Request (GET Invites)` ➔ `Split Out` ➔ `HTTP Request (POST Accept)`

1. **Detect New Invite (`Gmail Trigger`):** Listens for LinkedIn invitation emails in Gmail (`"wants to connect"`). Checking Gmail instead of polling LinkedIn every few minutes protects the LinkedIn account from automated scraping flags.
2. **Wait Delay (`Wait1`):** Pauses briefly (5–10 seconds) to mimic natural human timing.
3. **Fetch Pending Invites (`HTTP Request`):** Calls `GET https://api.unipile.com/v2/{account_id}/users/me/relation-requests?type=received` to list incoming requests.
4. **Accept Each Request (`Split Out` + `HTTP Request1`):** Splits the returned list and sends a `POST` request to `https://api.unipile.com/v2/{account_id}/users/me/relation-requests/{id}/accept` for each invitation.

### Workflow 2: Auto-Reply to Direct Messages
`Webhook` ➔ `Filter` ➔ `Wait` ➔ `AI Agent (Google Gemini)` ➔ `HTTP Request (POST Send)`

1. **Receive Message Event (`Webhook`):** Listens for real-time `message.new` webhook events sent by Unipile.
2. **Stop Self-Reply Loops (`Filter`):** Checks that `payload.is_sender` is `false`. Since Unipile sends webhook events for both incoming and outgoing messages, this filter ensures the bot only replies to messages from other people and never replies to itself.
3. **Typing Delay (`Wait`):** Waits 5–8 seconds before answering.
4. **Generate Human Reply (`AI Agent` + `Google Gemini`):** Reads the sender's name, headline, message text, and attachment/link metadata, then generates a short, natural reply (1–2 sentences):
   - Replies in the same language as the sender.
   - Handles short/emoji messages, long messages, links, attachments, rude messages, and unknown questions naturally.
   - Remembers conversation context using `chat_id` memory.
5. **Send Quoted Reply (`HTTP Request2`):** Sends the reply via `POST https://api.unipile.com/v2/{account_id}/chats/{chat_id}/messages/send` with `quote_id` set to the incoming message ID.

---

## 2. How to Run It

1. **Import the Workflow:**
   - Open **n8n** and import `workflow.json`.
2. **Add Credentials:**
   - Connect your **Gmail** account in the `Gmail Trigger` node.
   - Connect your **Google Gemini API Key** in the `Google Gemini Chat Model` node.
   - In the three `HTTP Request` nodes, replace `YOUR_UNIPILE_API_KEY` (in the `X-API-KEY` header) and `YOUR_UNIPILE_ACCOUNT_ID` (in the URL) with your Unipile credentials.
3. **Connect the Webhook in Unipile:**
   - Copy the **Production URL** from the n8n `Webhook` node.
   - In your Unipile Dashboard under **Webhooks**, add a new webhook for the `message.new` event pointing to that URL (or run `register_webhook.sh`).
4. **Start the Bot:**
   - Switch the n8n workflow toggle to **Active**.

---

## 3. What It Cannot Do Yet

- **Read Inside Image/File Attachments:** The bot detects when a file or image is attached and acknowledges it naturally, but it does not download the file to inspect its visual or document content.
- **Batch Rapid-Fire Messages:** If a user sends multiple messages within 1–2 seconds, Unipile triggers one webhook per message, so the bot replies to each message individually rather than waiting to combine them into a single reply.
- **Work Without Invite Emails:** Connection request acceptance relies on LinkedIn email notifications arriving in Gmail. If email notifications are turned off on LinkedIn, the trigger must be switched to a scheduled check.
