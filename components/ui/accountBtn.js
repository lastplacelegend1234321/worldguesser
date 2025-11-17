import { signIn } from "@/components/auth/auth";
import { FaGoogle } from "react-icons/fa";
import { useTranslation } from '@/components/useTranslations'
import sendEvent from "../utils/sendEvent";

export default function AccountBtn({ session, openAccountModal, navbarMode, inCrazyGames }) {
  const { t: text } = useTranslation("common");


  if(inCrazyGames && (!session || !session?.token?.secret)) {
    return null;
  }

  return (
    <>
    {!session || !session?.token?.secret ? (
        <button className={`gameBtn ${navbarMode ? 'navBtn' : 'accountBtn'}`} disabled={inCrazyGames} onClick={() => {
          if(session === null) {
            sendEvent("login_attempt")
            signIn('google')
          }
          }}>

        { !session?.token?.secret && session !== null ? '...' :
        (
          // <div style="margin-right: 10px; margin-left: 10px; display: flex; align-items: center; justify-content: center;">
          <div style={{marginRight: '10px',marginLeft: '10px', display: 'flex', alignItems: 'center', justifyContent: 'center'}}>

            {!inCrazyGames ? (
              <>
            Login
            </>
            ): (
              <>
            ...
            </>
            )}
          </div>
        )}
        </button>
    ) : (
        <button className={`gameBtn ${navbarMode ? 'navBtn' : 'accountBtn loggedIn'} ${session?.token?.supporter ? 'supporterBtn' : ''}`} onClick={() => {
        openAccountModal()
        }}>
          <span className="accountBtnText">
            {session?.token?.username || 'Account'}
          </span>
        </button>
    )}
    </>
  )
}