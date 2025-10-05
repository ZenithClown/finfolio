"use client"; // Required to disable SSR for Swagger UI

import dynamic from "next/dynamic";
import "swagger-ui-react/swagger-ui.css";

// Dynamically import to avoid SSR issues
const SwaggerUI = dynamic(() => import("swagger-ui-react"), { ssr: false });

export default function SwaggerDocsPage() {
  return (
    <div className="min-h-screen bg-white px-4 py-8">
      <h1 className="text-3xl font-bold mb-6 text-center">API Documentation</h1>
      <SwaggerUI url="http://localhost:3100/" />
    </div>
  );
}
