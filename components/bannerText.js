import NextImage from "next/image"
import earthLoading from "@/styles/images/earth_loading_worldguesser.png";

export default function BannerText({shown, text, hideCompass, subText, position}) {
  return (
    <div
      className={`banner-text ${shown ? 'shown' : 'hidden'}`}
      style={{
        position: position || 'fixed',
        zIndex: 1000,
        top: '50%',
        left: "50%",
        transform: "translate(-50%, -50%)",
        pointerEvents: 'none',
        flexDirection: 'column'
      }}
    >
      <div style={{ display: "flex"}}>
        <span style={{color: 'white', fontSize: '50px', marginTop: '20px', textAlign: 'center'}}>
          {text || 'Loading...'}
        </span>
        { !hideCompass && (
          <div className="loading-earth">
            <NextImage.default
              alt="Loading earth"
              src={earthLoading}
              width={120}
              height={120}
              priority
            />
          </div>
        )}
      </div>
      {subText && (
        <span style={{color: 'white', fontSize: '30px', marginTop: '20px', textAlign: 'center'}}>
          {subText}
        </span>
      )}
      <style jsx>{`
        @keyframes earth-spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }

        .loading-earth {
          display: inline-flex;
          align-items: center;
          justify-content: center;
          animation: earth-spin 4s linear infinite;
          filter: drop-shadow(0 8px 16px rgba(0, 0, 0, 0.3));
        }
      `}</style>
    </div>
  )
}