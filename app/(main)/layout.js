import HeaderComponent from "@/components/header";

const MainLayout = ({ children }) => {
  return (
    <div className="min-h-screen bg-gray-50">
      <HeaderComponent />
      <main className="pt-20 container mx-auto px-4">{children}</main>
    </div>
  );
};

export default MainLayout;
