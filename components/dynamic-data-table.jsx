"use client";

import { useEffect, useState, useMemo } from "react";
import PropTypes from "prop-types";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";

// Utility to build URL with query params
const buildUrlWithQuery = (endpoint, query) => {
  if (!query || Object.keys(query).length === 0) return endpoint;
  const params = new URLSearchParams(query);
  return `${endpoint}?${params.toString()}`;
};

export default function DynamicDataTable({
  endpoint,
  query = {},
  title = "Data Table",
  idField = "id", // Key to use as unique row identifier
  className = "",
}) {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const url = useMemo(() => buildUrlWithQuery(endpoint, query), [endpoint, query]);

  useEffect(() => {
    if (!endpoint) return;

    setLoading(true);
    setError(null);

    fetch(url)
      .then((res) => {
        if (!res.ok) throw new Error(`Failed to fetch: ${res.status}`);
        return res.json();
      })
      .then((data) => {
        // Normalize to always be an array
        const normalized = Array.isArray(data) ? data : [data];
        setData(normalized);
        setLoading(false);
      })
      .catch((err) => {
        console.error(err);
        setError(err.message);
        setLoading(false);
      });
  }, [url, endpoint]);

  // Detect dynamic columns based on first row
  const columns = useMemo(() => {
    if (data.length === 0) return [];
    return Object.keys(data[0]);
  }, [data]);

  // --- RENDER ---
  if (loading)
    return (
      <div className="text-gray-600 text-center py-6">
        Loading data from <span className="font-medium">{endpoint}</span>...
      </div>
    );

  if (error) return <div className="text-red-500 text-center py-6">❌ Error fetching data: {error}</div>;

  if (data.length === 0)
    return (
      <div className="text-gray-500 text-center py-6">
        ⚠️ No data found at <span className="font-medium">{endpoint}</span>
      </div>
    );

  return (
    <div className={`w-full max-w-6xl mx-auto bg-white rounded-2xl shadow-md border border-gray-200 p-6 mt-6 overflow-x-auto ${className}`}>
      <h2 className="text-xl font-semibold mb-4 text-gray-800">{title}</h2>

      <div className="min-w-[700px]">
        <Table>
          <TableHeader>
            <TableRow>
              {columns.map((col) => (
                <TableHead key={col} className="capitalize">
                  {col.replace(/_/g, " ")}
                </TableHead>
              ))}
            </TableRow>
          </TableHeader>

          <TableBody>
            {data.map((row) => (
              <TableRow key={row[idField] || JSON.stringify(row)}>
                {columns.map((col) => (
                  <TableCell key={col} className="text-gray-700">
                    {String(row[col] ?? "")}
                  </TableCell>
                ))}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}

DynamicDataTable.propTypes = {
  endpoint: PropTypes.string.isRequired,
  query: PropTypes.object,
  title: PropTypes.string,
  idField: PropTypes.string,
  className: PropTypes.string,
};
