import { Modal } from "react-responsive-modal";
import { useTranslation } from '@/components/useTranslations';
import gameStorage from "./utils/localStorage";

export default function DiscordModal({ shown, setOpen }) {
  const { t: text } = useTranslation("common");

  return (
    <Modal id="signUpModal" styles={{
        modal: {
            zIndex: 100,
            background: 'linear-gradient(135deg, rgba(24, 14, 58, 0.95) 0%, rgba(62, 34, 142, 0.93) 55%, rgba(24, 14, 58, 0.95) 100%)',
            color: 'white',
            padding: '28px',
            borderRadius: '24px',
            fontFamily: "'Montserrat', sans-serif",
            maxWidth: '520px',
            textAlign: 'center',
            border: '1px solid rgba(154, 129, 243, 0.35)',
            boxShadow: '0 20px 60px rgba(20, 10, 50, 0.55)'
        }
    }} open={shown} center onClose={() => {
        gameStorage.setItem("shownDiscordModal", Date.now().toString())
      setOpen(false)
    }}>

<h2>{text("joinDiscord")}</h2>
      <p>{text("joinDiscordDesc")}</p>

<iframe src="https://discord.com/widget?id=1229957469116301412&theme=dark" width="350"
height="350"
allowtransparency="true" frameborder="0" sandbox="allow-popups allow-popups-to-escape-sandbox allow-same-origin allow-scripts"></iframe>

<br/>

      <button onClick={() => {
          gameStorage.setItem("shownDiscordModal", Date.now().toString())

        setOpen(false)
      }} style={{
          background: 'linear-gradient(135deg, rgba(154, 129, 243, 0.2) 0%, rgba(112, 70, 227, 0.12) 100%)',
          color: 'white',
          padding: '12px 24px',
          borderRadius: '12px',
          border: '1px solid rgba(154, 129, 243, 0.35)',
          cursor: 'pointer',
          fontSize: '16px',
          fontWeight: 'bold',
          marginTop: '24px',
          marginLeft: '20px',
          boxShadow: '0 8px 18px rgba(112, 70, 227, 0.35)',
          transition: 'all 0.3s ease'
      }}>
        {text("notNow")}
      </button>
    </Modal>
  );
}
