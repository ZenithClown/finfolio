import { SignUp } from "@clerk/nextjs";

export default function SignInPage() {
  return <SignUp path="/signup" routing="path" />;
}
