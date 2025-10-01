import { Toaster } from "sonner";

import { Roboto_Mono } from "next/font/google";
import { ClerkProvider } from "@clerk/nextjs";

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

  keywords: [
    "finfolio",
    "personal finance",
    "offline finance management",
    "budget tracker",
    "self-hosted finance management application",
    "self-managed finance management application",
  ],

  authors: [
    {
      name: "Debmalya Pramanik",
      url: "https://www.linkedin.com/in/dpramanik/",
    },
  ],

  openGraph: {
    title: "FINFOLIO | Personal Offline Finance Management System",
    description: `
      Track expenses, budgets and savings offline or self-managed and
      self-hosted database using the FINFOLIO application.
    `,
  },
};

export default function RootLayout({ children }) {
  return (
    <ClerkProvider>
      <html lang="en">
        <head>
          <meta charSet="UTF-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1.0" />

          <link rel="icon" type="image/x-icon" href="/favicon.ico" sizes="any" />
        </head>

        <body className={defaultFont.className}>
          {/* header-component */}
          <HeaderComponent />

          <main className="min-h-screen">{children}</main>
          <Toaster richColors />

          {/* footer-component */}
          <footer className="bg-blue-50 py-12">
            <div className="container mx-auto text-center text-gray-600">
              <p>Copyright &copy; 2025 Project Finfolio - Personal Finance Management System</p>
              <small className="text-xs">Made with 💗 by Debmalya Pramanik</small>
            </div>
          </footer>
        </body>
      </html>
    </ClerkProvider>
  );
}
