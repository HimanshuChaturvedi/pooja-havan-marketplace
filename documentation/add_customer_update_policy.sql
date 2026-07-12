-- Enable customer to update their own order status (e.g. to 'paid' after checkout)
DROP POLICY IF EXISTS "Users can update own samagri orders" ON public.samagri_orders;
CREATE POLICY "Users can update own samagri orders" 
ON public.samagri_orders FOR UPDATE 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
