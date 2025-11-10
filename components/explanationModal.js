import { Modal } from "react-responsive-modal";
import { useState } from "react";
import { useTranslation } from '@/components/useTranslations';
import { toast } from "react-toastify";

export default function ExplanationModal({ lat, long, session, shown, onClose }) {
  const { t: text } = useTranslation("common");

  const [explanation, setExplanation] = useState('');
  const [error, setError] = useState(null);
  const [sending, setSending] = useState(false);

  const handleSubmit = async () => {
    if (!explanation) {
      setError("Explanation is required");
      return;
    }

    try {
      // send as form data
      // form data object
      const formData = new FormData();
      formData.append('lat', lat);
      formData.append('lng', long);
      formData.append('secret', session?.token?.secret);
      formData.append('clueText', explanation);
      setSending(true);


      const response = await fetch(window.cConfig.apiUrl+'/api/clues/makeClue', {
        method: 'POST',
        headers: {
          // 'Content-Type': 'application/json',
        },
        // body: JSON.stringify({
        //   lat,
        //   lng,
        //   secret: session?.token?.secret,
        //   clueText: explanation,
        // }),
        body: formData,

      });

      if (response.ok) {
      setSending(false);

        toast.success('Explanation submitted successfully!');
        setExplanation('');
        onClose();
      } else {
        const data = await response.json();
      setSending(false);

        setError(data.message || 'An error occurred');
      }
    } catch (err) {
      setSending(false);

      setError('An error occurred while submitting the explanation');
    }
  };

  return (
    <Modal
      id="explanationModal"
      styles={{
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
      }}
      open={shown}
      center
      onClose={onClose}
    >
      <h2>Write an explanation</h2>
      <p>Explain the reasoning behind your guess (in English)</p>
      <p>Be specific and explain specific details in the streetview that helped you pinpoint the country and region</p>
      <p style={{color: explanation.length < 100 ? "red" : "green"}}>({explanation.length} / 1000)</p>

      <textarea
        value={explanation}
        onChange={(e) => setExplanation(e.target.value)}
        placeholder={"Enter Explanation"}
        maxLength={1000}
        style={{
          width: '100%',
          height: '150px',
          padding: '10px',
          borderRadius: '12px',
          border: '1px solid rgba(154, 129, 243, 0.4)',
          marginBottom: '20px',
          fontSize: '16px',
          fontFamily: "'Montserrat', sans-serif",
          resize: 'none',
          background: 'rgba(255, 255, 255, 0.05)',
          color: 'white',
        }}
      />
      {error && <p style={{ color: 'red' }}>{error}</p>}
      <button
        onClick={handleSubmit}
        disabled={sending}
        style={{
          background: sending ? 'linear-gradient(135deg, rgba(112, 70, 227, 0.35) 0%, rgba(85, 50, 198, 0.35) 100%)' : 'linear-gradient(135deg, #9a81f3 0%, #7046e3 60%, #5532c6 100%)',
          color: 'white',
          padding: '14px 28px',
          borderRadius: '14px',
          border: 'none',
          cursor: sending ? 'not-allowed' : 'pointer',
          fontSize: '16px',
          fontWeight: 'bold',
          marginBottom: '20px',
          boxShadow: sending ? 'none' : '0 10px 24px rgba(112, 70, 227, 0.4)',
          transition: 'all 0.3s ease',
          opacity: sending ? 0.7 : 1
        }}
      >
        {sending ? text("loading") : "Submit Explanation"}
      </button>
    </Modal>
  );
}
