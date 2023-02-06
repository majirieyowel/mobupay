defmodule MobupayWhatsapp.Lang.Yoruba.Onboarding do
  def welcome_message(profile_name \\ "") do
    ~s"""
    Bawo #{profile_name} 👋🏾,
    Kaabọ si Mobupay.

    Pẹlu Mobupay o le firanṣẹ owo, ra akoko afẹfẹ ati data laifọwọyi ati ni aabo lati akọọlẹ yii.

    Lati ni imọ siwaju sii nipa bi mobupay ṣe n ṣiṣẹ, wo fidio yii: https://youtu.be/dQw4w9WgXcQ

    *Lati bẹrẹ, firanṣẹ adirẹsi imeeli rẹ si isalẹ*
    """
  end
end
