"use client";

import { useEffect, useState } from "react";

const ProfilePage = () => {
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
      <h1 className="text-2xl font-semibold">My Profile</h1>
      <div className="mt-4 space-y-2 text-gray-700">
        <p>
          <strong>Full Name:</strong> {user.fullName}
        </p>
        <p>
          <strong>Username:</strong> {user.username}
        </p>
        <p>
          <strong>Email:</strong> {user.email}
        </p>
        <p>
          <strong>Date of Birth:</strong> {user.dateOfBirth}
        </p>
      </div>
    </div>
  );
};

export default ProfilePage;
