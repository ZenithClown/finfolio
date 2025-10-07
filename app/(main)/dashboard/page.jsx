"use client";

import { useEffect, useState } from "react";
import DynamicDataTable from "@/components/dynamic-data-table";

const DashboardPage = () => {
  const [user, setUser] = useState(null);

  useEffect(() => {
    const storedUser = sessionStorage.getItem("user");
    if (storedUser) {
      setUser(JSON.parse(storedUser));
    } else {
      window.location.href = "/signin";
    }
  }, []);

  if (!user) return null;

  return (
    <div className="container mx-auto px-4">
      <h1 className="text-2xl font-semibold mt-4">Dashboard</h1>
      <p className="mt-2 text-gray-600">
        Welcome back, <span className="font-medium">{user.fullName || user.username}</span> 🎉
      </p>

      {/* Dynamic table for account types */}
      <DynamicDataTable endpoint="http://localhost:3100/expense_category" title="Account Types" />

      {/* Another example: Different endpoint with filters */}
      <DynamicDataTable endpoint="http://localhost:3100/expense_subcategory" title="Account Types" />
    </div>
  );
};

export default DashboardPage;
