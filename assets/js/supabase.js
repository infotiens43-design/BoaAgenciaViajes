import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm";

const SUPABASE_URL = "https://wzusuflfweagrtesimrk.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_xWX3UTb7ZVmGyw-Na8CkKw_Gvaq_Oj7";

export const supabase = createClient(
  SUPABASE_URL,
  SUPABASE_ANON_KEY
);
