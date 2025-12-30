// Supabase Configuration for MOFx EAs
// This file contains your Supabase project credentials

const SUPABASE_CONFIG = {
    url: 'https://xakzoaabyaqxgyyxvezb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhha3pvYWFieWFxeGd5eXh2ZXpiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjcwNjkyNzMsImV4cCI6MjA4MjY0NTI3M30.zCA3u10SmWaH6FeSqoFDH-MhDMlTgCcb2ICsor7WaPI'
};

// Business Configuration
const BUSINESS_CONFIG = {
    premiumPrice: 50.00,
    currency: 'USD',
    eaPriceRange: {
        min: 150,
        max: 300
    }
};

// Initialize Supabase Client
// This will be loaded in the HTML files via CDN
const supabase = window.supabase.createClient(SUPABASE_CONFIG.url, SUPABASE_CONFIG.anonKey);
