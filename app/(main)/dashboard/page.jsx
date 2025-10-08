"use client";

import { useEffect, useState } from "react";
import { Card, CardHeader, CardTitle, CardContent, CardFooter } from "@/components/ui/card";

export default function DashboardPage() {
  const [user, setUser] = useState(null);
  const [kpi, setKpi] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // --- Mock user session check ---
  useEffect(() => {
    const storedUser = sessionStorage.getItem("user");
    if (storedUser) {
      setUser(JSON.parse(storedUser));
    } else {
      window.location.href = "/signin";
    }
  }, []);

  // --- Fetch Net Worth KPI data ---
  useEffect(() => {
    const fetchNetWorth = async () => {
      try {
        const response = await fetch("http://localhost:3100/rpc/net_worth", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ p_account_id: [] }),
        });

        if (!response.ok) {
          throw new Error(`HTTP error: ${response.status}`);
        }

        const result = await response.json();
        setKpi(result);
      } catch (err) {
        console.error("Error fetching KPI:", err);
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchNetWorth();
  }, []);

  if (!user) return null;

  return (
    <div className="container mx-auto px-4 py-8">
      {/* Welcome Header */}
      <h1 className="text-2xl font-semibold">Dashboard</h1>
      <p className="mt-2 text-gray-600">
        Welcome back, <span className="font-medium">{user.fullName || user.username}</span> 🎉
      </p>

      {/* KPI Section */}
      <div className="mt-8 flex flex-wrap gap-6">
        {/* Net Worth KPI Card */}
        <Card className="w-64 text-center shadow-md border border-gray-300">
          <CardHeader className="pb-2">
            <CardTitle className="text-md font-semibold text-gray-800 uppercase tracking-wide">Net Worth</CardTitle>
          </CardHeader>

          <CardContent>
            {loading ? (
              <p className="text-gray-500 py-4">Loading...</p>
            ) : error ? (
              <p className="text-red-500 text-sm">{error}</p>
            ) : kpi ? (
              <div className="flex flex-col items-center">
                <span className="text-2xl font-bold text-gray-800 flex items-center justify-center">
                  ₹{" "}
                  {Number(kpi.net_value).toLocaleString("en-IN", {
                    minimumFractionDigits: 2,
                    maximumFractionDigits: 2,
                  })}
                </span>
              </div>
            ) : (
              <p className="text-gray-500 text-sm">No data</p>
            )}
          </CardContent>

          {!loading && !error && kpi && (
            <CardFooter className="pt-1 pb-2">
              <p className="text-xs text-gray-500 w-full text-center">Last Updated: {kpi.last_updated}</p>
            </CardFooter>
          )}
        </Card>
      </div>
    </div>
  );
}
