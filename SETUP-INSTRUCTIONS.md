# MOFx EAs - Supabase Integration Setup Guide

## 🎯 STEP-BY-STEP SETUP INSTRUCTIONS

### STEP 1: Setup Supabase Database

1. **Go to your Supabase project**: https://supabase.com/dashboard/project/xakzoaabyaqxgyyxvezb

2. **Open SQL Editor**:
   - Click "SQL Editor" in the left sidebar
   - Click "New Query"

3. **Run the Schema**:
   - Open the file `supabase-schema.sql`
   - Copy ALL the SQL code
   - Paste it into the Supabase SQL Editor
   - Click "Run" (or press Ctrl/Cmd + Enter)
   
4. **Wait for completion**:
   - You should see "Success. No rows returned" message
   - This creates all tables, triggers, and security policies

### STEP 2: Create Storage Buckets

1. **Go to Storage** in Supabase Dashboard

2. **Create these 4 buckets**:
   
   **Bucket 1: ea-files**
   - Click "New bucket"
   - Name: `ea-files`
   - Public: NO (Keep it private)
   - Click "Create bucket"
   
   **Bucket 2: tutorials**
   - Name: `tutorials`
   - Public: YES (Make it public for streaming)
   - Click "Create bucket"
   
   **Bucket 3: product-images**
   - Name: `product-images`
   - Public: YES
   - Click "Create bucket"
   
   **Bucket 4: user-avatars**
   - Name: `user-avatars`
   - Public: YES
   - Click "Create bucket"

3. **Set bucket policies** (Important for security):
   
   For **ea-files** (Private):
   - Only authenticated users who purchased the EA can download
   - Go to bucket → Policies → "New Policy"
   - Template: "Allow access to authenticated users only"
   
   For **tutorials** (Public):
   - Anyone can view, only you can upload
   - Policy is auto-set for public buckets

### STEP 3: Configure Email Templates

1. **Go to Authentication > Email Templates**

2. **Confirm signup template**:
   ```html
   <h2>Welcome to MOFx EAs!</h2>
   <p>Hi {{ .FullName }},</p>
   <p>Thanks for signing up! Click below to confirm your email:</p>
   <p><a href="{{ .ConfirmationURL }}">Confirm your email</a></p>
   <p>Welcome to automated trading excellence!</p>
   <p>Best regards,<br>MOFx EAs Team</p>
   ```

3. **Reset password template**:
   ```html
   <h2>Reset Your Password</h2>
   <p>Hi {{ .FullName }},</p>
   <p>Click below to reset your password:</p>
   <p><a href="{{ .ConfirmationURL }}">Reset Password</a></p>
   <p>If you didn't request this, please ignore this email.</p>
   ```

### STEP 4: Enable Social Login (Optional)

1. **Go to Authentication > Providers**

2. **Enable Google**:
   - Toggle "Google" to ON
   - You'll need Google OAuth credentials
   - Follow Supabase guide: https://supabase.com/docs/guides/auth/social-login/auth-google

3. **Enable Facebook**:
   - Toggle "Facebook" to ON
   - You'll need Facebook App credentials
   - Follow Supabase guide: https://supabase.com/docs/guides/auth/social-login/auth-facebook

### STEP 5: Test Your Setup

1. **Open `login.html` in your browser**

2. **Try to Sign Up**:
   - Enter name, email, password
   - Click "Create Account"
   - Check your email for confirmation link
   - Click the link to verify

3. **Check Database**:
   - Go to Supabase → Table Editor
   - Click on `users` table
   - You should see your new user!

4. **Try to Login**:
   - Use your email and password
   - Should redirect to dashboard

---

## 📊 WHAT EACH TABLE DOES

### `users`
- Stores user profile information
- Linked to Supabase Auth
- Tracks premium membership status

### `products`
- Your EA catalog (6 products pre-loaded)
- Each EA has price, description, features
- You can add more EAs anytime

### `purchases`
- Records every EA purchase
- Links users to products they bought
- Tracks payment status and method
- Counts downloads

### `tutorials`
- Video tutorial library (14 tutorials pre-loaded)
- 6 free, 8 premium
- Tracks views and duration

### `premium_subscriptions`
- Tracks premium tutorial access
- $50 one-time payment
- Lifetime access

### `download_logs`
- Security & analytics
- Tracks every EA download
- Prevents abuse

### `support_tickets`
- Customer support system
- Users can submit tickets
- You manage them

---

## 🔐 SECURITY FEATURES ENABLED

✅ **Row Level Security (RLS)**
- Users can only see their own data
- Prevents data leaks
- Automatic enforcement

✅ **Secure Authentication**
- Passwords hashed with bcrypt
- Session management
- JWT tokens

✅ **Protected Downloads**
- EA files require authentication
- Time-limited download links
- One purchase = access forever

---

## 💳 NEXT: PAYMENT INTEGRATION

### Option 1: Paystack (Card Payments)

You'll need to:
1. Get Paystack API keys from paystack.com
2. Create a webhook endpoint
3. Verify payments in Supabase

I can help you integrate this next!

### Option 2: Crypto (Manual)

Current flow:
1. User clicks "Pay with Crypto"
2. Opens your Telegram
3. You verify payment manually
4. You activate their purchase in Supabase

I can create an admin panel to make this easier!

---

## 🎨 FILE STRUCTURE

```
mofx-eas/
├── mofx-eas.html          → Homepage
├── login.html             → Login/Signup (✅ Supabase integrated)
├── dashboard.html         → User Dashboard (✅ Supabase integrated)
├── tutorials.html         → Tutorials page
├── product-scalper-pro.html → Product page
├── supabase-config.js     → Your credentials
├── supabase-schema.sql    → Database setup
└── images/                → All logos
```

---

## 🚀 WHAT'S WORKING NOW

✅ User signup with email verification
✅ User login with session management
✅ Dashboard showing real user data
✅ Protected routes (login required)
✅ User profile display
✅ Premium member status
✅ Purchase history
✅ Download tracking
✅ Secure logout

---

## 🔜 WHAT'S NEXT

I can build:

1. **Paystack Integration**
   - Verify card payments automatically
   - Activate EA access instantly
   - Generate receipts

2. **Admin Panel**
   - Manage users
   - Manage products
   - View purchases
   - Grant premium access
   - Handle support tickets

3. **Premium Content Protection**
   - Auto-unlock tutorials for premium users
   - Show premium badge

4. **Email Notifications**
   - Welcome emails
   - Purchase confirmations
   - Download links

Let me know which one you want me to build first! 🎯
