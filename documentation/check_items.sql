-- Check Samagri Order Items Schema and Data
SELECT 
    column_name, 
    data_type 
FROM information_schema.columns 
WHERE table_name = 'samagri_order_items';

-- Check items for the problematic standalone order
SELECT * FROM samagri_order_items WHERE order_id IN (
    SELECT id FROM samagri_orders WHERE reference_id = 'PHM-SMG-2026-822856'
);
