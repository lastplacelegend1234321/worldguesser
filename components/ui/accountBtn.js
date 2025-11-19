import { signIn } from "@/components/auth/auth";
import { useTranslation } from '@/components/useTranslations'
import sendEvent from "../utils/sendEvent";

export default function AccountBtn({ session, openAccountModal, navbarMode, inCrazyGames }) {
  const { t: text } = useTranslation("common");

  if (session?.token?.secret) {
    return null;
  }

  if (inCrazyGames && (!session || !session?.token?.secret)) {
    return null;
  }

  return (
    <>
      {!session || !session?.token?.secret ? (
        <button
          className={`gameBtn ${navbarMode ? 'navBtn' : 'accountBtn'}`}
          disabled={inCrazyGames}
          onClick={() => {
            if (session === null) {
              sendEvent("login_attempt");
              signIn('google');
            }
          }}
        >
          {!session?.token?.secret && session !== null ? '...' : (
            <div style={{ marginRight: '10px', marginLeft: '10px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              {!inCrazyGames ? (
                <>Login</>
              ) : (
                <>...</>
              )}
            </div>
          )}
        </button>
      ) : null}
    </>
  )
}
