using UnityEngine;

public class Vzemi : MonoBehaviour
{
    private CapsuleCollider2D igra4;
    private Kruv kruv;
    private CapsuleCollider2D az_col;

    [SerializeField]
    GameObject az;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        igra4 = GameObject.FindGameObjectWithTag("Player").GetComponent<CapsuleCollider2D>();
        kruv = GameObject.FindGameObjectWithTag("Player").GetComponent<Kruv>();
        az_col = az.GetComponent<CapsuleCollider2D>();
    }

    // Update is called once per frame
    void Update()
    {

    }

    void FixedUpdate()
    {
        if (igra4.IsTouching(az_col))
        {
            kruv.Vzemi();
            Destroy(az);
            igra4.attachedRigidbody.AddForce(new Vector2(0, 1.5f), ForceMode2D.Impulse);
        }
    }
}
