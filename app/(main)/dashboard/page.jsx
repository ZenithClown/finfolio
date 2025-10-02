"use client";

import { useEffect, useState } from "react";

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
    <div>
      <h1 className="text-2xl font-semibold">Dashboard</h1>
      <p className="mt-2 text-gray-600">
        Welcome back, <span className="font-medium">{user.fullName || user.username}</span> 🎉
      </p>
    </div>
  );
};

export default DashboardPage;
