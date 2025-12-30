-- MOFx EAs Database Schema for Supabase
-- Run this in your Supabase SQL Editor

-- =============================================
-- 1. USERS TABLE (extends auth.users)
-- =============================================
CREATE TABLE public.users (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone_number TEXT,
    is_premium_member BOOLEAN DEFAULT FALSE,
    premium_expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Users can only read and update their own data
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Auto-create user profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, full_name, email)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
        NEW.email
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =============================================
-- 2. PRODUCTS TABLE (EAs Catalog)
-- =============================================
CREATE TABLE public.products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    category TEXT NOT NULL, -- 'scalper', 'trend', 'grid', 'news', 'multi', 'hedge'
    icon TEXT DEFAULT '🤖',
    image_url TEXT,
    file_url TEXT, -- Supabase Storage URL
    documentation_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    features JSONB, -- Array of features
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- Anyone can view active products
CREATE POLICY "Anyone can view active products" ON public.products
    FOR SELECT USING (is_active = TRUE);

-- Insert initial products
INSERT INTO public.products (name, slug, description, price, category, icon, features) VALUES
('Scalper Pro EA', 'scalper-pro', 'High-frequency trading system designed for quick market entries and exits. Optimized for low-latency execution on major currency pairs with advanced risk controls.', 299.00, 'scalper', '⚡', 
'["Advanced price action scalping algorithm", "Intelligent spread filter", "Dynamic stop-loss and take-profit", "Multi-timeframe analysis", "Configurable risk management", "News filter option"]'::jsonb),

('Trend Master EA', 'trend-master', 'Intelligent trend-following algorithm that identifies and capitalizes on strong market movements. Features dynamic position sizing and adaptive stop-loss management.', 249.00, 'trend', '📈',
'["Momentum-based trend detection", "Adaptive position sizing", "Dynamic stop-loss management", "Multiple technical indicators", "Trend strength filter", "Trailing stop feature"]'::jsonb),

('Grid Trader EA', 'grid-trader', 'Advanced grid trading system with smart recovery mechanisms. Designed for ranging markets with configurable grid spacing and profit targets.', 199.00, 'grid', '🔷',
'["Smart grid placement", "Recovery mechanisms", "Configurable grid spacing", "Dynamic profit targets", "Range detection", "Maximum drawdown protection"]'::jsonb),

('News Trader EA', 'news-trader', 'Specialized EA for trading major economic news releases. Features pre-news positioning, volatility filters, and rapid execution capabilities.', 279.00, 'news', '📰',
'["Economic calendar integration", "Pre-news positioning", "Volatility filters", "Rapid execution", "News impact analysis", "Risk management for high volatility"]'::jsonb),

('Multi-Pair EA', 'multi-pair', 'Diversified trading across multiple currency pairs simultaneously. Includes correlation analysis and portfolio risk management features.', 299.00, 'multi', '🌐',
'["Multi-pair trading", "Correlation analysis", "Portfolio risk management", "Diversification strategy", "Individual pair controls", "Global risk limits"]'::jsonb),

('Smart Hedge EA', 'smart-hedge', 'Sophisticated hedging system that protects your positions during adverse market conditions while maintaining profit potential.', 249.00, 'hedge', '🛡️',
'["Advanced hedging strategies", "Position protection", "Profit preservation", "Market condition analysis", "Dynamic hedge sizing", "Risk mitigation"]'::jsonb);

-- =============================================
-- 3. PURCHASES TABLE
-- =============================================
CREATE TABLE public.purchases (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
    amount_paid DECIMAL(10, 2) NOT NULL,
    payment_method TEXT NOT NULL, -- 'card', 'crypto'
    payment_status TEXT DEFAULT 'pending', -- 'pending', 'completed', 'failed'
    transaction_reference TEXT UNIQUE,
    purchased_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    download_count INTEGER DEFAULT 0,
    last_downloaded_at TIMESTAMP WITH TIME ZONE
);

-- Enable RLS
ALTER TABLE public.purchases ENABLE ROW LEVEL SECURITY;

-- Users can only view their own purchases
CREATE POLICY "Users can view own purchases" ON public.purchases
    FOR SELECT USING (auth.uid() = user_id);

-- Create index for faster queries
CREATE INDEX idx_purchases_user_id ON public.purchases(user_id);
CREATE INDEX idx_purchases_transaction_ref ON public.purchases(transaction_reference);

-- =============================================
-- 4. TUTORIALS TABLE
-- =============================================
CREATE TABLE public.tutorials (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    duration TEXT NOT NULL, -- e.g., "12:34"
    video_url TEXT,
    thumbnail_url TEXT,
    is_premium BOOLEAN DEFAULT FALSE,
    category TEXT, -- 'beginner', 'intermediate', 'advanced'
    order_index INTEGER DEFAULT 0,
    views_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.tutorials ENABLE ROW LEVEL SECURITY;

-- Anyone can view tutorial metadata
CREATE POLICY "Anyone can view tutorials" ON public.tutorials
    FOR SELECT USING (TRUE);

-- Insert initial tutorials
INSERT INTO public.tutorials (title, description, duration, is_premium, category, order_index) VALUES
('Introduction to Expert Advisors', 'Learn the basics of automated trading and how Expert Advisors work on MetaTrader platforms.', '12:34', FALSE, 'beginner', 1),
('Installing Your First EA', 'Step-by-step guide to installing and activating Expert Advisors on MT4 and MT5.', '15:20', FALSE, 'beginner', 2),
('Complete MT4/MT5 Setup Guide', 'Configure your MetaTrader platform for optimal EA performance and trading experience.', '18:45', FALSE, 'beginner', 3),
('Understanding Risk Management', 'Essential risk management principles for automated trading success and capital preservation.', '22:10', FALSE, 'beginner', 4),
('Broker Account Setup Guide', 'How to choose and set up your broker account for EA trading with our partner brokers.', '16:30', FALSE, 'beginner', 5),
('EA Settings Explained', 'Understanding basic EA parameters and how to adjust them for your trading style.', '20:15', FALSE, 'beginner', 6),
('Advanced EA Optimization Techniques', 'Master advanced optimization strategies to maximize EA performance across different market conditions.', '35:20', TRUE, 'advanced', 7),
('Multi-Timeframe Analysis Mastery', 'Learn to use multiple timeframes for better trade entries and higher win rates with your EAs.', '28:45', TRUE, 'advanced', 8),
('Portfolio Management Strategies', 'Build and manage a diversified EA portfolio for consistent returns and reduced risk.', '42:30', TRUE, 'advanced', 9),
('Custom EA Settings Configuration', 'Deep dive into advanced EA parameters and custom configurations for each market condition.', '38:15', TRUE, 'advanced', 10),
('Live Trading Psychology Mastery', 'Develop the mental discipline required for successful automated trading and EA management.', '45:00', TRUE, 'advanced', 11),
('News Trading with EAs', 'Advanced strategies for trading major news events using automated systems safely.', '32:50', TRUE, 'advanced', 12),
('VPS Setup & Optimization', 'Complete guide to setting up and optimizing your VPS for 24/7 EA trading.', '40:20', TRUE, 'advanced', 13),
('Backtesting & Forward Testing', 'Professional techniques for testing EAs before live deployment to ensure profitability.', '36:40', TRUE, 'advanced', 14);

-- =============================================
-- 5. PREMIUM SUBSCRIPTIONS TABLE
-- =============================================
CREATE TABLE public.premium_subscriptions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    subscription_type TEXT DEFAULT 'lifetime', -- Always 'lifetime' for one-time payment
    amount_paid DECIMAL(10, 2) DEFAULT 50.00,
    payment_method TEXT NOT NULL, -- 'card', 'crypto'
    payment_reference TEXT UNIQUE,
    starts_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.premium_subscriptions ENABLE ROW LEVEL SECURITY;

-- Users can view their own subscription
CREATE POLICY "Users can view own subscription" ON public.premium_subscriptions
    FOR SELECT USING (auth.uid() = user_id);

-- =============================================
-- 6. DOWNLOAD LOGS TABLE
-- =============================================
CREATE TABLE public.download_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
    downloaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ip_address TEXT,
    user_agent TEXT
);

-- Enable RLS
ALTER TABLE public.download_logs ENABLE ROW LEVEL SECURITY;

-- Users can view their own download history
CREATE POLICY "Users can view own downloads" ON public.download_logs
    FOR SELECT USING (auth.uid() = user_id);

-- Create index
CREATE INDEX idx_download_logs_user_id ON public.download_logs(user_id);

-- =============================================
-- 7. SUPPORT TICKETS TABLE
-- =============================================
CREATE TABLE public.support_tickets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    subject TEXT NOT NULL,
    message TEXT NOT NULL,
    status TEXT DEFAULT 'open', -- 'open', 'in_progress', 'resolved', 'closed'
    priority TEXT DEFAULT 'medium', -- 'low', 'medium', 'high'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.support_tickets ENABLE ROW LEVEL SECURITY;

-- Users can view their own tickets
CREATE POLICY "Users can view own tickets" ON public.support_tickets
    FOR SELECT USING (auth.uid() = user_id);

-- Users can create tickets
CREATE POLICY "Users can create tickets" ON public.support_tickets
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- =============================================
-- 8. FUNCTIONS & TRIGGERS
-- =============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to users table
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Apply to products table
CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON public.products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Apply to support tickets
CREATE TRIGGER update_tickets_updated_at
    BEFORE UPDATE ON public.support_tickets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to check if user has purchased a product
CREATE OR REPLACE FUNCTION user_has_purchased(p_product_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.purchases
        WHERE user_id = auth.uid()
        AND product_id = p_product_id
        AND payment_status = 'completed'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user has premium access
CREATE OR REPLACE FUNCTION user_is_premium()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.users
        WHERE id = auth.uid()
        AND is_premium_member = TRUE
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to activate premium access after payment
CREATE OR REPLACE FUNCTION activate_premium_access(p_user_id UUID, p_payment_reference TEXT)
RETURNS VOID AS $$
BEGIN
    -- Update user to premium
    UPDATE public.users
    SET is_premium_member = TRUE,
        updated_at = NOW()
    WHERE id = p_user_id;
    
    -- Record subscription
    INSERT INTO public.premium_subscriptions (user_id, payment_reference)
    VALUES (p_user_id, p_payment_reference);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- 9. STORAGE BUCKETS (Run these in Supabase Dashboard)
-- =============================================
-- You'll need to create these buckets in Supabase Dashboard > Storage:
-- 1. 'ea-files' - for EA downloads (.ex4, .ex5 files)
-- 2. 'tutorials' - for tutorial videos
-- 3. 'product-images' - for EA product images
-- 4. 'user-avatars' - for user profile pictures

-- =============================================
-- SETUP COMPLETE!
-- =============================================
-- Next steps:
-- 1. Run this SQL in your Supabase SQL Editor
-- 2. Create Storage Buckets in Supabase Dashboard
-- 3. The web app will handle the rest!
