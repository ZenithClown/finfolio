"use client";

import { useEffect, useState, useMemo } from "react";
import PropTypes from "prop-types";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";

// 🔧 Helper function: build API URL with query parameters
const buildUrlWithQuery = (endpoint, query) => {
  if (!query || Object.keys(query).length === 0) return endpoint;
  const params = new URLSearchParams(query);
  return `${endpoint}?${params.toString()}`;
};

export default function DynamicDataTable({
  endpoint,
  query = {},
  title = "Data Table",
  idField = "id",
  maxVisibleRows, // 👈 PARAMETRIC (user-defined per instance)
  className = "",
}) {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Rebuild URL if endpoint or query changes
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

  // 🧠 Detect columns dynamically
  const columns = useMemo(() => {
    if (data.length === 0) return [];
    return Object.keys(data[0]);
  }, [data]);

  // 📏 Dynamically compute max height based on maxVisibleRows param
  // Roughly assume 3rem per row (including padding)
  const bodyMaxHeight = maxVisibleRows ? `${maxVisibleRows * 3.1}rem` : "auto";

  // --- UI States ---
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

  // --- MAIN TABLE RENDER ---
  return (
    <div className={`w-full max-w-6xl mx-auto bg-white rounded-2xl shadow-md border border-gray-200 p-6 mt-6 ${className}`}>
      <h2 className="text-xl font-semibold mb-4 text-gray-800">{title}</h2>

      {/* Outer scrollable container */}
      <div className="min-w-[700px] overflow-x-auto">
        <div className={`overflow-y-auto border-t border-gray-100 ${maxVisibleRows ? "scroll-smooth" : ""}`} style={{ maxHeight: bodyMaxHeight }}>
          <Table>
            <TableHeader className="sticky top-0 bg-gray-50 z-10">
              <TableRow>
                {columns.map((col) => (
                  <TableHead key={col} className="capitalize text-sm font-semibold text-gray-700">
                    {col.replace(/_/g, " ")}
                  </TableHead>
                ))}
              </TableRow>
            </TableHeader>

            <TableBody>
              {data.map((row, index) => (
                <TableRow key={row[idField] || index} className="hover:bg-gray-50 transition-colors">
                  {columns.map((col) => (
                    <TableCell key={col} className="text-gray-700 text-sm">
                      {String(row[col] ?? "")}
                    </TableCell>
                  ))}
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      </div>
    </div>
  );
}

// 🧾 Prop validation
DynamicDataTable.propTypes = {
  endpoint: PropTypes.string.isRequired,
  query: PropTypes.object,
  title: PropTypes.string,
  idField: PropTypes.string,
  maxVisibleRows: PropTypes.number, // 👈 Parametric prop
  className: PropTypes.string,
};
