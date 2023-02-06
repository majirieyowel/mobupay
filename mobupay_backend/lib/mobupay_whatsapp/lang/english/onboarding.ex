defmodule MobupayWhatsapp.Lang.English.Onboarding do
  def welcome_message(profile_name \\ "") do
    ~s"""
    Hello #{profile_name} 👋🏾,
    Welcome to Mobupay.

    With Mobupay you can securely send and receive money from any whatsapp number.

    To learn more about how mobupay works, watch this video: https://youtu.be/dQw4w9WgXcQ

    👇👇
    *To get started, send us your email address below*
    """
  end

  def email_verification_sent(email) do
    ~s"""
    A verification link has been sent to your email: *#{email}*
    Please verify your email so we know it's you.

    1. Resend verification link
    2. Use another email
    """
  end

  def email_required_prompt() do
    options_list = [
      "Please reply with your email address to proceed with your account.",
      "Your email address is required for the next steps.",
      "Please enter your email address below."
    ]

    "#{Enum.random(options_list)}"
  end

  def verification_link_resent(email) do
    ~s"""
    The verification link has been resent!. Please check your mail: #{email}
    """
  end

  def new_email_to_use() do
    ~s"""
    Please enter another email you will like to use
    """
  end

  def verify_email_remind(email) do
    ~s"""
    Please verify your email by clicking on the link sent to #{email}.

    1. Resend verification link
    2. Use another email
    """
  end

  def email_verified(email) do
    # Send \"help\" for instructions on how to use Mobupay.
    ~s"""
    Your email (#{email}) has been confirmed successfully! 🥳.

    Next, secure your account by clicking on the link:

    https://mobupay-l0il401s0-majirieyowel.vercel.app/secure-whatsapp-device/7e2ad0ce-92a4-11ed-8980-6e0925fdd49d

    Security Token: 8 0 2 2 9 3
    """
  end
end
