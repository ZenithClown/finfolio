"use client";

import { useEffect, useState } from "react";
import { Card, CardHeader, CardTitle, CardContent, CardFooter } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { Popover, PopoverTrigger, PopoverContent } from "@/components/ui/popover";
import { ChevronDown } from "lucide-react";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, ResponsiveContainer, LabelList } from "recharts";

export default function DashboardPage() {
  const [user, setUser] = useState(null);
  const [accounts, setAccounts] = useState([]);
  const [selectedAccounts, setSelectedAccounts] = useState([]);
  const [netWorth, setNetWorth] = useState(null);
  const [chartData, setChartData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    const storedUser = sessionStorage.getItem("user");
    if (storedUser) {
      setUser(JSON.parse(storedUser));
    } else {
      window.location.href = "/signin";
    }
  }, []);

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
        setSelectedAccounts(accountList.map((a) => a.id));
      } catch (err) {
        console.error("Account fetch error:", err);
        setError(err.message);
      }
    };
    fetchAccounts();
  }, []);

  useEffect(() => {
    if (selectedAccounts.length === 0) return;

    const fetchData = async () => {
      setLoading(true);
      setError(null);
      try {
        const resKpi = await fetch("http://localhost:3100/rpc/net_worth", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ p_account_id: selectedAccounts }),
        });
        if (!resKpi.ok) throw new Error("Failed to fetch net worth");
        const kpiData = await resKpi.json();
        setNetWorth(kpiData);

        const resChart = await fetch("http://localhost:3100/rpc/net_value_by_account", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ p_account_id: selectedAccounts }),
        });
        if (!resChart.ok) throw new Error("Failed to fetch chart data");
        const chart = await resChart.json();

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

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-2xl sm:text-3xl md:text-4xl font-semibold">Portfolio Overview</h1>
      <p className="mt-2 text-gray-600 text-sm sm:text-base md:text-lg">
        Welcome back, <span className="font-medium">{user.fullName || user.username}</span> 🎉
      </p>

      <div className="mt-8 flex gap-4">
        {/* Left Column: Account Selector + KPI Cards */}
        <div className="flex flex-col w-[30%] h-[300px] gap-4">
          {/* Account Selector (10% height) */}
          <div className="flex-1" style={{ flex: 0.1 }}>
            <Popover open={dropdownOpen} onOpenChange={setDropdownOpen}>
              <PopoverTrigger asChild>
                <Button variant="outline" className="flex items-center justify-between min-w-[280px] text-xs sm:text-sm md:text-base">
                  {allSelected ? "All Accounts Selected" : `${selectedAccounts.length} selected`}
                  <ChevronDown className="ml-2 h-4 w-4" />
                </Button>
              </PopoverTrigger>
              <PopoverContent className="w-[280px] max-h-[320px] overflow-y-auto p-2 text-xs sm:text-sm md:text-base">
                <div className="flex items-center space-x-2 p-2 border-b">
                  <Checkbox id="selectAll" checked={allSelected} onCheckedChange={toggleSelectAll} />
                  <label htmlFor="selectAll" className="font-medium">
                    Select All
                  </label>
                </div>
                {accounts.map((acc) => (
                  <div key={acc.id} className="flex items-center space-x-2 p-2 hover:bg-gray-50 rounded-md">
                    <Checkbox checked={selectedAccounts.includes(acc.id)} onCheckedChange={() => toggleAccount(acc.id)} id={acc.id} />
                    <label htmlFor={acc.id} className="cursor-pointer">
                      {acc.name}
                    </label>
                  </div>
                ))}
              </PopoverContent>
            </Popover>
          </div>

          {/* Net Worth KPI Card (remaining 90% height) */}
          <div className="flex-1" style={{ flex: 0.9 }}>
            <Card className="h-full text-center shadow-md border border-gray-300 flex flex-col">
              <CardHeader className="pb-2">
                <CardTitle className="text-md sm:text-lg md:text-xl font-semibold text-gray-800 uppercase tracking-wide">Net Worth</CardTitle>
              </CardHeader>
              <CardContent className="flex-1 flex items-center justify-center">
                {loading ? (
                  <p className="text-gray-500 py-4 text-sm sm:text-base md:text-lg">Loading...</p>
                ) : error ? (
                  <p className="text-red-500 text-sm">{error}</p>
                ) : netWorth ? (
                  <span className="text-xl font-bold text-gray-800 flex items-center justify-center">
                    ₹{" "}
                    {Number(netWorth.net_value).toLocaleString("en-IN", {
                      minimumFractionDigits: 2,
                      maximumFractionDigits: 2,
                    })}
                  </span>
                ) : (
                  <p className="text-gray-500 text-sm sm:text-base md:text-lg">No data</p>
                )}
              </CardContent>
              {!loading && !error && netWorth && (
                <CardFooter className="pt-1 pb-2 text-xs sm:text-sm md:text-base">
                  <p className="w-full text-center">Last Updated: {netWorth.last_updated}</p>
                </CardFooter>
              )}
            </Card>
          </div>
        </div>

        {/* Right Column: Bar Chart */}
        <div className="w-[70%] h-[300px]">
          <Card className="h-full shadow-md border border-gray-300 flex flex-col">
            <CardHeader className="pb-2">
              <CardTitle className="text-md sm:text-lg md:text-xl font-semibold text-gray-800 uppercase tracking-wide">Net Value by Account</CardTitle>
            </CardHeader>
            <CardContent className="flex-1 p-0 flex justify-center items-center">
              {loading ? (
                <p className="text-gray-500 text-center py-8 text-sm sm:text-base md:text-lg">Loading Chart...</p>
              ) : (
                <div className="w-[100%] h-[95%]">
                  <ResponsiveContainer width="100%" height="100%">
                    <BarChart
                      layout="vertical"
                      data={chartData}
                      margin={{ top: 10, right: 20, left: -75, bottom: 10 }} // removed left padding
                    >
                      <CartesianGrid strokeDasharray="3 3" />
                      <XAxis
                        type="number"
                        tickFormatter={(value) => `₹ ${Number(value).toLocaleString("en-IN", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`}
                      />
                      <YAxis type="category" dataKey="name" width={150} />
                      <Bar dataKey="value" fill="#3b82f6" radius={[4, 4, 4, 4]}>
                        <LabelList
                          dataKey="value"
                          position="right"
                          formatter={(value) => `₹ ${Number(value).toLocaleString("en-IN", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`}
                        />
                      </Bar>
                    </BarChart>
                  </ResponsiveContainer>
                </div>
              )}
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
