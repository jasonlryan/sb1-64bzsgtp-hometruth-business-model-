/*
  # Complete Schema Setup

  1. New Tables
    - active_subscribers (user subscription tracking)
    - cogs (cost of goods sold)
    - departments (company departments and staffing)
    - operating_expenses (operational costs)
    - funding_rounds (investment history)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users
*/

-- Active Subscribers
CREATE TABLE IF NOT EXISTS active_subscribers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  month text NOT NULL,
  existing_subs integer NOT NULL DEFAULT 0,
  new_deals integer NOT NULL DEFAULT 0,
  churned_subs integer NOT NULL DEFAULT 0,
  ending_subs integer NOT NULL DEFAULT 0,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE active_subscribers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own active subscribers data"
  ON active_subscribers
  FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- COGS
CREATE TABLE IF NOT EXISTS cogs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category text NOT NULL,
  monthly_cost numeric NOT NULL DEFAULT 0,
  notes text,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE cogs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own COGS data"
  ON cogs
  FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Departments
CREATE TABLE IF NOT EXISTS departments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  fte numeric NOT NULL DEFAULT 0,
  salary numeric NOT NULL DEFAULT 0,
  additional_costs numeric NOT NULL DEFAULT 0,
  monthly_total numeric NOT NULL DEFAULT 0,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE departments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own departments data"
  ON departments
  FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Operating Expenses
CREATE TABLE IF NOT EXISTS operating_expenses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category text NOT NULL,
  monthly_cost numeric NOT NULL DEFAULT 0,
  notes text,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE operating_expenses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own operating expenses data"
  ON operating_expenses
  FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Funding Rounds
CREATE TABLE IF NOT EXISTS funding_rounds (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  round text NOT NULL,
  amount_raised numeric NOT NULL DEFAULT 0,
  valuation_pre numeric NOT NULL DEFAULT 0,
  equity_sold numeric NOT NULL DEFAULT 0,
  close_date text,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE funding_rounds ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own funding rounds data"
  ON funding_rounds
  FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Create or replace the updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for all tables
CREATE TRIGGER update_active_subscribers_updated_at
  BEFORE UPDATE ON active_subscribers
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_cogs_updated_at
  BEFORE UPDATE ON cogs
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_departments_updated_at
  BEFORE UPDATE ON departments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_operating_expenses_updated_at
  BEFORE UPDATE ON operating_expenses
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_funding_rounds_updated_at
  BEFORE UPDATE ON funding_rounds
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();