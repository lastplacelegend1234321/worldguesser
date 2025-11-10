import { Modal } from "react-responsive-modal";
import { useTranslation } from '@/components/useTranslations';

export default function SettingsModal({ shown, onClose, options, setOptions, inCrazyGames }) {
    const { t: text } = useTranslation("common");

    const handleUnitsChange = (event) => {
        setOptions((prevOptions) => ({ ...prevOptions, units: event.target.value }));
    };

    const handleMapTypeChange = (event) => {
        setOptions((prevOptions) => ({ ...prevOptions, mapType: event.target.value }));
    };

    const handleLanguageChange = (event) => {
        setOptions((prevOptions) => ({ ...prevOptions, language: event.target.value }));
    };

    if (!options) return null;

    return (
        <Modal
            styles={{
                modal: {
                    zIndex: 1000,
                    color: 'white',
                    padding: '28px',
                    borderRadius: '24px',
                    maxWidth: '420px',
                    textAlign: 'center',
                    background: 'linear-gradient(135deg, rgba(126, 86, 239, 0.96) 0%, rgba(85, 50, 198, 0.92) 100%)',
                    border: '2px solid rgba(179, 156, 255, 0.4)',
                    boxShadow: '0 18px 40px rgba(20, 10, 40, 0.45)',
                    backdropFilter: 'blur(20px)'
                },
                closeButton: {
                    display: 'none'
                }
            }}
            classNames={{ overlay: 'settingsOverlay' }}
            open={shown}
            center
            onClose={onClose}
            showCloseIcon={false}
            animationDuration={150}
        >
            <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
                <h1 style={{ fontSize: '2.4rem', margin: 0 }}>{text("settings")}</h1>

                <div style={{ display: 'flex', flexDirection: 'column', gap: '16px', textAlign: 'left' }}>
                    <label style={{ display: 'flex', flexDirection: 'column', gap: '8px', fontWeight: 500 }}>
                        <span>{text("units")}</span>
                        <select className="g2_input" value={options.units} onChange={handleUnitsChange}>
                            <option value="metric">{text("metric")}</option>
                            <option value="imperial">{text("imperial")}</option>
                        </select>
                    </label>

                    <label style={{ display: 'flex', flexDirection: 'column', gap: '8px', fontWeight: 500 }}>
                        <span>{text("mapType")}</span>
                        <select className="g2_input" value={options.mapType} onChange={handleMapTypeChange}>
                            <option value="m">{text("normal")}</option>
                            <option value="s">{text("satellite")}</option>
                            <option value="p">{text("terrain")}</option>
                            <option value="y">{text("hybrid")}</option>
                        </select>
                    </label>

                    {!inCrazyGames && (
                        <label style={{ display: 'flex', flexDirection: 'column', gap: '8px', fontWeight: 500 }}>
                            <span>{text("language")}</span>
                            <select className="g2_input" value={options.language} onChange={handleLanguageChange}>
                                <option value="en">English</option>
                                <option value="es">Español</option>
                                <option value="fr">Français</option>
                                <option value="de">Deutsch</option>
                                <option value="ru">Русский</option>
                            </select>
                        </label>
                    )}
                </div>

                {inCrazyGames && (
                    <a href="/privacy-crazygames" target="_blank" rel="noreferrer" style={{ color: "white", opacity: 0.85 }}>
                        Privacy Policy
                    </a>
                )}

                <button
                    onClick={onClose}
                    style={{
                        marginTop: '8px',
                        background: 'linear-gradient(135deg, #ff9a6b, #ff6a45)',
                        color: 'white',
                        border: 'none',
                        padding: '12px 24px',
                        borderRadius: '20px',
                        fontWeight: 600,
                        cursor: 'pointer',
                        boxShadow: '0 10px 25px rgba(255, 106, 69, 0.35)',
                    }}
                >
                    {text("back")}
                </button>
            </div>
        </Modal>
    );
}