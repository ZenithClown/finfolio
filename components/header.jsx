"use client";

import Link from "next/link";
import Image from "next/image";
import { useEffect, useState } from "react";
import { Button } from "./ui/button";
import { LayoutDashboard, LogOut } from "lucide-react";
import { useRouter } from "next/navigation";

const HeaderComponent = () => {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const router = useRouter();

  useEffect(() => {
    setIsLoggedIn(sessionStorage.getItem("isLoggedIn") === "true");
  }, []);

  const handleSignOut = () => {
    sessionStorage.clear();
    setIsLoggedIn(false);
    router.push("/signin");
  };

  return (
    <header className="fixed top-0 w-full bg-white/80 backdrop-blur-md z-50 border-b">
      <nav className="container mx-auto px-4 py-4 flex items-center justify-between">
        {/* Logo */}
        <Link href="/">
          <Image src={"/favicon.png"} width={200} height={64} className="h-12 w-auto object-contain" alt="finfolio logo" />
        </Link>

        {/* Navigation Links - Dynamic */}
        <div className="hidden md:flex items-center space-x-8">
          {!isLoggedIn ? (
            <>
              <a href="/swagger" className="text-gray-600 hover:text-blue-600">
                Swagger UI
              </a>
              <a href="https://github.com/ZenithClown/finfolio" className="text-gray-600 hover:text-blue-600" target="_blank">
                Source Code
              </a>
            </>
          ) : (
            <>
              <Link href="/dashboard" className="text-gray-600 hover:text-blue-600 flex items-center gap-2">
                <LayoutDashboard size={18} />
                <span>My Dashboard</span>
              </Link>
              <Link href="/profile" className="text-gray-600 hover:text-blue-600">
                My Profile
              </Link>
            </>
          )}
        </div>

        {/* Right side buttons */}
        <div className="flex items-center space-x-4">
          {!isLoggedIn ? (
            <>
              <Link href="/signin">
                <Button variant="outline">Sign In</Button>
              </Link>
              <Link href="/signup">
                <Button>Sign Up</Button>
              </Link>
            </>
          ) : (
            <Button variant="outline" onClick={handleSignOut}>
              <LogOut size={18} />
              <span className="hidden md:inline">Sign Out</span>
            </Button>
          )}
        </div>
      </nav>
    </header>
  );
};

export default HeaderComponent;
