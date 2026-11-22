-- JIBOFY withdrawal status guard
-- Run once in Supabase SQL Editor after reviewing.
-- Only authenticated admins may change request status or payment reference.
-- Allowed transitions: pending -> approved/rejected; approved -> paid/rejected.
CREATE OR REPLACE FUNCTION public.jibofy_guard_withdrawal_updates()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_is_admin boolean;
BEGIN
  IF NEW.status IS DISTINCT FROM OLD.status
     OR NEW.transaction_id IS DISTINCT FROM OLD.transaction_id THEN
    SELECT EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'admin'
    ) INTO v_is_admin;

    IF NOT v_is_admin THEN
      RAISE EXCEPTION 'Only administrators can update withdrawal status or payment reference';
    END IF;
  END IF;

  IF OLD.status IN ('paid', 'rejected') AND NEW.status IS DISTINCT FROM OLD.status THEN
    RAISE EXCEPTION 'Paid or rejected withdrawal requests are final';
  END IF;

  IF NEW.status = 'approved' AND OLD.status <> 'pending' THEN
    RAISE EXCEPTION 'Only pending requests can be approved';
  END IF;

  IF NEW.status = 'paid' AND OLD.status <> 'approved' THEN
    RAISE EXCEPTION 'Only approved requests can be marked paid';
  END IF;

  IF NEW.status = 'paid' AND length(trim(coalesce(NEW.transaction_id, ''))) = 0 THEN
    RAISE EXCEPTION 'A payment transaction ID is required before marking paid';
  END IF;

  IF NEW.transaction_id IS NOT NULL AND length(trim(NEW.transaction_id)) = 0 THEN
    NEW.transaction_id := NULL;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS jibofy_guard_withdrawal_updates ON public.withdrawals;
CREATE TRIGGER jibofy_guard_withdrawal_updates
BEFORE UPDATE ON public.withdrawals
FOR EACH ROW
EXECUTE FUNCTION public.jibofy_guard_withdrawal_updates();
