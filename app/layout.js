import { Roboto_Mono } from "next/font/google";
import "./globals.css";

import HeaderComponent from "@/components/header";

const defaultFont = Roboto_Mono({
  variable: "--font-roboto-mono",
  subsets: ["latin"],
});

export const metadata = {
  title: "FINFOLIO | Personal Offline Finance Management System",

  description: `
    Project Finfolio - A personal finance management and analysis system that
    is built with Next.js and Tailwind CSS. The system provides the latest AI
    tools to help and suggest improvement areas for users. Unlike most other
    third-party tools/platforms the application is secured and the data is
    private by default by storing the data in the user's local system or a cloud
    database of choice.
  `,

  keywords:[
    "finfolio", "personal finance", "offline finance management",
    "budget tracker", "self-hosted finance management application",
    "self-managed finance management application"
  ],

  authors: [{
    name: "Debmalya Pramanik",
    url: "https://www.linkedin.com/in/dpramanik/"
  }],

  openGraph: {
    title: "FINFOLIO | Personal Offline Finance Management System",
    description: `
      Track expenses, budgets and savings offline or self-managed and
      self-hosted database using the FINFOLIO application.
    `,
  }
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body className={defaultFont.className}>
        {/* header-component */}
        < HeaderComponent />

        <main className="min-h-screen">
          {children}
        </main>

        {/* footer-component */}
        <footer className="bg-blue-50 py-12">
          <div className="container mx-auto text-center text-gray-600">
            <p>Copyright &copy; 2025 Project Finfolio, Debmalya Pramanik</p>
          </div>
        </footer>
      </body>
    </html>
  );
}
