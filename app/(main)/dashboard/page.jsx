"use client";

import { useEffect, useState } from "react";
import { Card, CardHeader, CardTitle, CardContent, CardFooter } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { Popover, PopoverTrigger, PopoverContent } from "@/components/ui/popover";
import { ChevronDown } from "lucide-react";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from "recharts";

export default function DashboardPage() {
  const [user, setUser] = useState(null);
  const [accounts, setAccounts] = useState([]);
  const [selectedAccounts, setSelectedAccounts] = useState([]);
  const [netWorth, setNetWorth] = useState(null);
  const [chartData, setChartData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const [error, setError] = useState(null);

  // --- STEP 1: Check session ---
  useEffect(() => {
    const storedUser = sessionStorage.getItem("user");
    if (storedUser) {
      setUser(JSON.parse(storedUser));
    } else {
      window.location.href = "/signin";
    }
  }, []);

  // --- STEP 2: Fetch Account List ---
  useEffect(() => {
    const fetchAccounts = async () => {
      try {
        const res = await fetch("http://localhost:3100/ledger_account_json");
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const result = await res.json();

        const jsonAgg = result[0]?.json_agg || [];
        const accountList = jsonAgg.map((obj) => {
          const [id, name] = Object.entries(obj)[0];
          return { id, name };
        });

        setAccounts(accountList);
        setSelectedAccounts(accountList.map((a) => a.id)); // Default: all selected
      } catch (err) {
        console.error("Account fetch error:", err);
        setError(err.message);
      }
    };
    fetchAccounts();
  }, []);

  // --- STEP 3: Fetch KPI + Chart Data ---
  useEffect(() => {
    if (selectedAccounts.length === 0) return;

    const fetchData = async () => {
      setLoading(true);
      setError(null);

      try {
        // Fetch Net Worth KPI
        const resKpi = await fetch("http://localhost:3100/rpc/net_worth", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ p_account_id: selectedAccounts }),
        });

        if (!resKpi.ok) throw new Error("Failed to fetch net worth");
        const kpiData = await resKpi.json();
        setNetWorth(kpiData);

        // Fetch Bar Chart Data
        const resChart = await fetch("http://localhost:3100/rpc/net_value_by_account", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ p_account_id: selectedAccounts }),
        });

        if (!resChart.ok) throw new Error("Failed to fetch chart data");
        const chart = await resChart.json();

        // Expected format: [{ account_id, account_name, net_value }]
        const formattedChart = chart.map((d) => ({
          name: d.account_name || d.account_id,
          value: d.net_value,
        }));

        setChartData(formattedChart);
      } catch (err) {
        console.error(err);
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [selectedAccounts]);

  // --- STEP 4: Handle Selection ---
  const toggleAccount = (id) => {
    if (selectedAccounts.includes(id)) {
      setSelectedAccounts(selectedAccounts.filter((x) => x !== id));
    } else {
      setSelectedAccounts([...selectedAccounts, id]);
    }
  };

  const allSelected = selectedAccounts.length === accounts.length;
  const toggleSelectAll = () => {
    if (allSelected) {
      setSelectedAccounts([]);
    } else {
      setSelectedAccounts(accounts.map((a) => a.id));
    }
  };

  if (!user) return null;

  // --- STEP 5: Render ---
  return (
    <div className="container mx-auto px-4 py-8">
      {/* Header */}
      <h1 className="text-2xl font-semibold">My Dashboard</h1>
      <p className="mt-2 text-gray-600">
        Welcome back, <span className="font-medium">{user.fullName || user.username}</span> 🎉
      </p>

      {/* Account Selector */}
      <div className="mt-6">
        <Popover open={dropdownOpen} onOpenChange={setDropdownOpen}>
          <PopoverTrigger asChild>
            <Button variant="outline" className="flex items-center justify-between min-w-[280px]">
              {allSelected ? "All Accounts Selected" : `${selectedAccounts.length} selected`}
              <ChevronDown className="ml-2 h-4 w-4" />
            </Button>
          </PopoverTrigger>
          <PopoverContent className="w-[280px] max-h-[320px] overflow-y-auto p-2">
            <div className="flex items-center space-x-2 p-2 border-b">
              <Checkbox id="selectAll" checked={allSelected} onCheckedChange={toggleSelectAll} />
              <label htmlFor="selectAll" className="text-sm font-medium">
                Select All
              </label>
            </div>
            {accounts.map((acc) => (
              <div key={acc.id} className="flex items-center space-x-2 p-2 hover:bg-gray-50 rounded-md">
                <Checkbox checked={selectedAccounts.includes(acc.id)} onCheckedChange={() => toggleAccount(acc.id)} id={acc.id} />
                <label htmlFor={acc.id} className="text-sm text-gray-700 cursor-pointer">
                  {acc.name}
                </label>
              </div>
            ))}
          </PopoverContent>
        </Popover>
      </div>

      {/* KPI + Chart Section */}
      <div className="mt-8 grid grid-cols-1 md:grid-cols-2 gap-6 items-start">
        {/* Net Worth KPI Card */}
        <Card className="w-full text-center shadow-md border border-gray-300">
          <CardHeader className="pb-2">
            <CardTitle className="text-md font-semibold text-gray-800 uppercase tracking-wide">Net Worth</CardTitle>
          </CardHeader>

          <CardContent>
            {loading ? (
              <p className="text-gray-500 py-4">Loading...</p>
            ) : error ? (
              <p className="text-red-500 text-sm">{error}</p>
            ) : netWorth ? (
              <div className="flex flex-col items-center">
                <span className="text-2xl font-bold text-gray-800 flex items-center justify-center">
                  ₹{" "}
                  {Number(netWorth.net_value).toLocaleString("en-IN", {
                    minimumFractionDigits: 2,
                    maximumFractionDigits: 2,
                  })}
                </span>
              </div>
            ) : (
              <p className="text-gray-500 text-sm">No data</p>
            )}
          </CardContent>

          {!loading && !error && netWorth && (
            <CardFooter className="pt-1 pb-2">
              <p className="text-xs text-gray-500 w-full text-center">Last Updated: {netWorth.last_updated}</p>
            </CardFooter>
          )}
        </Card>

        {/* Bar Chart */}
        <Card className="w-full h-[300px] shadow-md border border-gray-300">
          <CardHeader className="pb-2">
            <CardTitle className="text-md font-semibold text-gray-800 uppercase tracking-wide">Net Value by Account</CardTitle>
          </CardHeader>

          <CardContent className="pt-2">
            {loading ? (
              <p className="text-gray-500 text-center py-8">Loading Chart...</p>
            ) : (
              <ResponsiveContainer width="100%" height={220}>
                <BarChart data={chartData} margin={{ top: 10, right: 10, left: 0, bottom: 30 }}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" angle={-30} textAnchor="end" height={60} tick={{ fontSize: 12 }} />
                  <YAxis />
                  <Tooltip
                    formatter={(value) =>
                      `₹ ${Number(value).toLocaleString("en-IN", {
                        minimumFractionDigits: 2,
                        maximumFractionDigits: 2,
                      })}`
                    }
                  />
                  <Bar dataKey="value" fill="#3b82f6" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
