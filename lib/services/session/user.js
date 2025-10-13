/**
 * Safely Retrieve & Parse User Object from Session Storage
 *
 * This function is designed to run only on the client-side. It checks
 * for the presence of a "user" object in `sessionStorage` and returns
 * it if found. It returns null if the code is running on the server,
 * if the user object is not found, or if there is a parsing error.
 *
 * @returns {object|null} : Parsed User Object from Session Storage
 */

export default function getSessionUser() {
  if (typeof window !== "undefined") {
    const storedUser = sessionStorage.getItem("user");
    if (storedUser) {
      try {
        return JSON.parse(storedUser);
      } catch (error) {
        console.error("Failed to parse user from session storage", error);
        return null;
      }
    }
  }
  return null;
}
