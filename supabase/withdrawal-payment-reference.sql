-- JIBOFY withdrawal payment reference
-- Run once in Supabase SQL Editor after reviewing the change.
ALTER TABLE public.withdrawals
  ADD COLUMN IF NOT EXISTS transaction_id text;

ALTER TABLE public.withdrawals
  DROP CONSTRAINT IF EXISTS withdrawals_transaction_id_length_check;

ALTER TABLE public.withdrawals
  ADD CONSTRAINT withdrawals_transaction_id_length_check
  CHECK (transaction_id IS NULL OR length(trim(transaction_id)) BETWEEN 1 AND 80);

CREATE UNIQUE INDEX IF NOT EXISTS withdrawals_method_transaction_id_unique
  ON public.withdrawals (lower(trim(method)), upper(trim(transaction_id)))
  WHERE transaction_id IS NOT NULL AND length(trim(transaction_id)) > 0;

COMMENT ON COLUMN public.withdrawals.transaction_id IS
  'Manual bKash, Nagad or Rocket transaction reference entered by an administrator after payment is sent.';
