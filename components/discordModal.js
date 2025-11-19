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

      <a 
        href="https://discord.gg/azbS3F2wmb" 
        target="_blank" 
        rel="noopener noreferrer"
        onClick={() => {
          gameStorage.setItem("shownDiscordModal", Date.now().toString())
          setOpen(false)
        }}
        style={{
          display: 'inline-block',
          background: 'linear-gradient(135deg, #5865F2 0%, #7289DA 100%)',
          color: 'white',
          padding: '14px 32px',
          borderRadius: '12px',
          border: 'none',
          cursor: 'pointer',
          fontSize: '18px',
          fontWeight: 'bold',
          marginTop: '24px',
          textDecoration: 'none',
          boxShadow: '0 8px 18px rgba(88, 101, 242, 0.4)',
          transition: 'all 0.3s ease'
        }}
        onMouseEnter={(e) => {
          e.target.style.transform = 'translateY(-2px)';
          e.target.style.boxShadow = '0 12px 24px rgba(88, 101, 242, 0.5)';
        }}
        onMouseLeave={(e) => {
          e.target.style.transform = 'translateY(0)';
          e.target.style.boxShadow = '0 8px 18px rgba(88, 101, 242, 0.4)';
        }}
      >
        Join Discord Server
      </a>

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
          marginTop: '16px',
          boxShadow: '0 8px 18px rgba(112, 70, 227, 0.35)',
          transition: 'all 0.3s ease'
      }}>
        {text("notNow")}
      </button>
    </Modal>
  );
}
