-- Sprint 4A: Vendor Reject Workflow database migration
-- Adds rejection details columns and updated_at to public.samagri_orders

ALTER TABLE public.samagri_orders 
ADD COLUMN IF NOT EXISTS reject_reason TEXT,
ADD COLUMN IF NOT EXISTS reject_reason_details TEXT,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
