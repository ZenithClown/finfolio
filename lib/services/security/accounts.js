import { API_RPC_BASE } from "@/app/config/constants";

/**
 * Get the List of KPI Values Typically for Dashboard Design
 *
 * The query are designed only to work when a user is logged in and
 * always takes the default parameter "username" which is typically
 * passed to the RESTful API as ``p_username`` in JSON format.
 *
 * The underlying function and SQL definition is available under the
 * /dashboard/api/security/*.sql files which are named the same as
 * this file name for easy reference and naming convention.
 *
 * @returns {Promise<object|null>} : List of Account by Type for User
 */

export async function getAccounts() {
  const res = await fetch("http://localhost:3100/ledger_account_json");
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  const result = await res.json();
  const jsonAgg = result[0]?.json_agg || [];
  // Transform the data into a more usable format
  return jsonAgg.map((obj) => {
    const [id, name] = Object.entries(obj)[0];
    return { id, name };
  });
}

/**
 * Fetches the net worth for a given set of account IDs.
 * @param {string[]} selectedAccounts - An array of account IDs.
 * @returns {Promise<object|null>} The net worth data or null if no accounts are provided.
 */
export async function getNetWorth(selectedAccounts) {
  if (!selectedAccounts || selectedAccounts.length === 0) {
    return null;
  }
  const res = await fetch("http://localhost:3100/rpc/net_worth", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ p_account_id: selectedAccounts }),
  });
  if (!res.ok) throw new Error("Failed to fetch net worth");
  return res.json();
}

/**
 * Fetches the net value by account for the chart.
 * @param {string[]} selectedAccounts - An array of account IDs.
 * @returns {Promise<object[]>} The formatted data for the chart.
 */
export async function getChartData(selectedAccounts) {
  if (!selectedAccounts || selectedAccounts.length === 0) {
    return [];
  }
  const res = await fetch("http://localhost:3100/rpc/net_value_by_account", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ p_account_id: selectedAccounts }),
  });
  if (!res.ok) throw new Error("Failed to fetch chart data");
  const chart = await res.json();
  // Transform the data for the chart component
  return chart.map((d) => ({
    name: d.account_name || d.account_id,
    value: d.net_value,
  }));
}
