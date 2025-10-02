import Link from "next/link";
import Image from "next/image";

import { Button } from "./ui/button";
import { LayoutDashboard } from "lucide-react";

const HeaderComponent = () => {
  return (
    <header className="fixed top-0 w-full bg-white/80 backdrop-blur-md z-50 border-b">
      <nav className="container mx-auto px-4 py-4 flex items-center justify-between">
        <Link href="/">
          <Image src={"/favicon.png"} width={200} height={64} className="h-12 w-auto object-contain" alt="finfolio logo" />
        </Link>

        {/* Navigation Links - Dynamic based on User State */}
        <div className="hidden md:flex items-center space-x-8">
          <a href="#manual" className="text-gray-600 hover:text-blue-600">
            User Manual
          </a>
          <a href="#" className="text-gray-600 hover:text-blue-600">
            Source Code
          </a>
        </div>

        {/* User Action Buttons - Dynamic based on User State */}
        <div className="flex items-center space-x-4">
          <Link href="/dashboard" className="text-gray-600 hover:text-blue-600 flex items-center gap-2">
            <Button variant="outline">
              <LayoutDashboard size={18} />
              <span className="hidden md:inline">Dashboard</span>
            </Button>
          </Link>
        </div>
      </nav>
    </header>
  );
};

export default HeaderComponent;
