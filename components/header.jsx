import { SignInButton, SignUpButton, SignedIn, SignedOut, UserButton } from "@clerk/nextjs";

const HeaderComponent = () => {
  const buttonClasses = "text-ceramic-white rounded-full font-medium text-sm sm:text-base h-10 sm:h-12 px-4 sm:px-5 cursor-pointer";

  return (
    <header className="fixed top-0 left-0 right-0 justify-end items-center p-4 gap-4 h-16">
      <SignedOut>
        <SignInButton>
          <button className={`${buttonClasses} bg-blue-100`}>Sign In</button>
        </SignInButton>
        <SignUpButton>
          <button className={`${buttonClasses} bg-blue-300`}>Sign Up</button>
        </SignUpButton>
      </SignedOut>
      <SignedIn>
        <UserButton />
      </SignedIn>
    </header>
  );
};

export default HeaderComponent;
