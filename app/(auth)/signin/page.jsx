"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

const SigninPage = () => {
  const router = useRouter();
  const [form, setForm] = useState({ email: "", password: "" });

  const handleSubmit = (e) => {
    e.preventDefault();

    const storedUser = JSON.parse(sessionStorage.getItem("user") || "{}");
    if (storedUser && (storedUser.email === form.email || storedUser.username === form.email) && storedUser.password === form.password) {
      sessionStorage.setItem("isLoggedIn", "true");
      router.push("/dashboard");
    } else {
      alert("Invalid credentials");
    }
  };

  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-50 px-4">
      <form onSubmit={handleSubmit} className="w-full max-w-md bg-white shadow-lg rounded-xl p-6 space-y-4">
        <h1 className="text-2xl font-semibold text-center">Sign In</h1>

        <Input type="text" placeholder="Email or Username" value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} className="mb-3" />
        <Input type="password" placeholder="Password" value={form.password} onChange={(e) => setForm({ ...form, password: e.target.value })} className="mb-3" />

        <Button type="submit" className="w-full">
          Sign In
        </Button>

        <p className="text-sm text-center text-gray-600">
          Don't have an account?{" "}
          <a href="/signup" className="text-blue-600 hover:underline">
            Sign Up
          </a>
        </p>
      </form>
    </div>
  );
};

export default SigninPage;
