-- Check how many Samagri orders exist and who they are assigned to
SELECT 
  vendor_id, 
  status, 
  count(*) 
FROM public.samagri_orders 
GROUP BY vendor_id, status;

-- Check if any orders have NULL vendor_id (orphaned)
SELECT id, total_amount, created_at 
FROM public.samagri_orders 
WHERE vendor_id IS NULL;
