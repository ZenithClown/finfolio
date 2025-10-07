"use client";

import DynamicDataTable from "@/components/dynamic-data-table";

export default function Home() {
  return (
    <div className="container mx-auto px-4">
      <h1 className="text-2xl font-semibold mt-4">About Project</h1>
      <p className="mt-2 text-gray-600">
        Project <code>finfolio</code> is a personal finance management and analysis system that helps individuals track income, expenses, savings, and
        investments with Python, PostgreSQL, and interactive NextJS dashboards.
      </p>

      <h2 className="text-xl font-semibold mt-4">Getting Started</h2>
      <p className="mt-2 text-gray-600">
        The project is already initialized with seed data, meaning you can quickly start inserting the data rather than spend time creating your own master data
        and sub-table relationships. The following master tables are available:
      </p>

      {/* Dynamic table for account types */}
      <DynamicDataTable
        endpoint="http://localhost:3100/account_types"
        title="Account Types"
        subtitle="Detailed list of different account types and their subtypes are displayed with a note on each type of field."
        maxVisibleRows={5}
      />
    </div>
  );
}
